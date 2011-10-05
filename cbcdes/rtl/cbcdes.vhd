-- ======================================================================
-- CBC-DES encryption/decryption
-- algorithm according to FIPS 46-3 specification
-- Copyright (C) 2007 Torsten Meissner
-------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- ======================================================================


-- Revision 0.1  2011/09/23
-- Initial release, incomplete and may contain bugs


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.des_pkg.all;


entity cbcdes is
  port (
    reset_i     : in  std_logic;                  -- low active async reset
    clk_i       : in  std_logic;                  -- clock
    start_i     : in  std_logic;                  -- start cbc
    mode_i      : in  std_logic;                  -- des-modus: 0 = encrypt, 1 = decrypt
    key_i       : in  std_logic_vector(0 TO 63);  -- key input
    iv_i        : in  std_logic_vector(0 to 63);  -- iv input
    data_i      : in  std_logic_vector(0 TO 63);  -- data input
    valid_i     : in  std_logic;                  -- input key/data valid flag
    ready_o     : out std_logic;                  -- ready to encrypt/decrypt
    data_o      : out std_logic_vector(0 TO 63);  -- data output
    valid_o     : out std_logic                   -- output data valid flag
  );
end entity cbcdes;


architecture rtl of cbcdes is


  component des is
    port (
      clk_i       : IN  std_logic;                  -- clock
      mode_i      : IN  std_logic;                  -- des-modus: 0 = encrypt, 1 = decrypt
      key_i       : IN  std_logic_vector(0 TO 63);  -- key input
      data_i      : IN  std_logic_vector(0 TO 63);  -- data input
      valid_i     : IN  std_logic;                  -- input key/data valid flag
      data_o      : OUT std_logic_vector(0 TO 63);  -- data output
      valid_o     : OUT std_logic                   -- output data valid flag
    );
  end component des;
 

  signal s_mode       : std_logic;
  signal s_start      : std_logic;
  signal s_iv         : std_logic_vector(0 to 63);
  signal s_datain     : std_logic_vector(0 to 63);
  signal s_des_datain : std_logic_vector(0 to 63);
  signal s_validin    : std_logic;
  signal s_dataout    : std_logic_vector(0 to 63);
  signal s_validout   : std_logic;
  signal s_ready      : std_logic;
  signal s_reset      : std_logic;
 

begin


  s_des_datain <= iv_i xor data_i      when mode_i = '0' and start_i = '1' else
                  s_dataout xor data_i when mode_i = '0' and start_i = '0' else
                  data_i;
  data_o       <= s_iv xor s_dataout     when s_mode = '1' and s_start = '1' else
                  s_datain xor s_dataout when s_mode = '1' and s_start = '0' else
                  s_dataout;

  ready_o     <= s_ready;
  s_validin   <= valid_i and s_ready;
  valid_o     <= s_validout;

  inputregister : process(clk_i, reset_i) is
  begin
    if(reset_i = '0') then
      s_reset  <= '0';
      s_mode   <= '0';
      s_start  <= '0';
      s_iv     <= (others => '0');
      s_datain <= (others => '0');
    elsif(rising_edge(clk_i)) then
      s_reset  <= reset_i;
      if(valid_i = '1' and s_ready = '1') then
        s_start  <= start_i;
        s_datain <= data_i;
      end if;
      if(valid_i = '1' and s_ready = '1' and start_i = '1') then
        s_mode   <= mode_i;
        s_iv     <= iv_i;
      end if;
    end if;
  end process inputregister;


  outputregister : process(clk_i, reset_i) is
  begin
    if(reset_i = '0') then
      s_ready <= '0';
    elsif(rising_edge(clk_i)) then
      if(valid_i = '1' and s_ready = '1') then
        s_ready <= '0';
      end if;
      if(s_validout = '1' or (reset_i = '1' and s_reset = '0')) then
        s_ready <= '1';
      end if;
    end if;
  end process outputregister;
      

  i_des : des
    port map (
      clk_i   => clk_i,
      mode_i  => mode_i,
      key_i   => key_i,
      data_i  => s_des_datain,
      valid_i => s_validin,
      data_o  => s_dataout,
      valid_o => s_validout
    );


end architecture rtl;
