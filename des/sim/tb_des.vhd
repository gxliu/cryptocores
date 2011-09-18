-- ======================================================================
-- DES encryption/decryption testbench
-- tests according to NIST 800-16 special publication
-- Copyright (C) 2011 Torsten Meissner
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


-- Revision 1.0   2011/09/17
-- Initial release
-- Revision 1.0.1 2011/09/18
-- tests partial adopted to NIST 800-16 publication
-- Revision 1.0.2 2011/09/18
-- includes more tests of NIST 800-16 publication


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_des is
end entity tb_des;


architecture rtl of tb_des is


  type t_array is array (natural range <>) of std_logic_vector(0 to 63);
  
  signal s_variable_plaintext_known_answers : t_array(0 to 63) :=
    (x"95F8A5E5DD31D900", x"DD7F121CA5015619", x"2E8653104F3834EA",
     x"4BD388FF6CD81D4F", x"20B9E767B2FB1456", x"55579380D77138EF",
     x"6CC5DEFAAF04512F", x"0D9F279BA5D87260", x"D9031B0271BD5A0A",
     x"424250B37C3DD951", x"B8061B7ECD9A21E5", x"F15D0F286B65BD28",
     x"ADD0CC8D6E5DEBA1", x"E6D5F82752AD63D1", x"ECBFE3BD3F591A5E",
     x"F356834379D165CD", x"2B9F982F20037FA9", x"889DE068A16F0BE6",
     x"E19E275D846A1298", x"329A8ED523D71AEC", x"E7FCE22557D23C97",
     x"12A9F5817FF2D65D", x"A484C3AD38DC9C19", x"FBE00A8A1EF8AD72",
     x"750D079407521363", x"64FEED9C724C2FAF", x"F02B263B328E2B60",
     x"9D64555A9A10B852", x"D106FF0BED5255D7", x"E1652C6B138C64A5",
     x"E428581186EC8F46", x"AEB5F5EDE22D1A36", x"E943D7568AEC0C5C",
     x"DF98C8276F54B04B", x"B160E4680F6C696F", x"FA0752B07D9C4AB8",
     x"CA3A2B036DBC8502", x"5E0905517BB59BCF", x"814EEB3B91D90726",
     x"4D49DB1532919C9F", x"25EB5FC3F8CF0621", x"AB6A20C0620D1C6F", 
     x"79E90DBC98F92CCA", x"866ECEDD8072BB0E", x"8B54536F2F3E64A8",
     x"EA51D3975595B86B", x"CAFFC6AC4542DE31", x"8DD45A2DDF90796C",
     x"1029D55E880EC2D0", x"5D86CB23639DBEA9", x"1D1CA853AE7C0C5F",
     x"CE332329248F3228", x"8405D1ABE24FB942", x"E643D78090CA4207",
     x"48221B9937748A23", x"DD7C0BBD61FAFD54", x"2FBC291A570DB5C4",
     x"E07C30D7E4E26E12", x"0953E2258E8E90A1", x"5B711BC4CEEBF2EE",
     x"CC083F1E6D9E85F6", x"D2FD8867D50D2DFE", x"06E7EA22CE92708F",
     x"166B40B44ABA4BD6");

  signal s_variable_key_known_answers : t_array(0 to 55) :=
    (x"95A8D72813DAA94D", x"0EEC1487DD8C26D5", x"7AD16FFB79C45926",
     x"D3746294CA6A6CF3", x"809F5F873C1FD761", x"C02FAFFEC989D1FC",
     x"4615AA1D33E72F10", x"2055123350C00858", x"DF3B99D6577397C8",
     x"31FE17369B5288C9", x"DFDD3CC64DAE1642", x"178C83CE2B399D94",
     x"50F636324A9B7F80", x"A8468EE3BC18F06D", x"A2DC9E92FD3CDE92",
     x"CAC09F797D031287", x"90BA680B22AEB525", x"CE7A24F350E280B6",
     x"882BFF0AA01A0B87", x"25610288924511C2", x"C71516C29C75D170",
     x"5199C29A52C9F059", x"C22F0A294A71F29F", x"EE371483714C02EA",
     x"A81FBD448F9E522F", x"4F644C92E192DFED", x"1AFA9A66A6DF92AE",
     x"B3C1CC715CB879D8", x"19D032E64AB0BD8B", x"3CFAA7A7DC8720DC",
     x"B7265F7F447AC6F3", x"9DB73B3C0D163F54", x"8181B65BABF4A975",
     x"93C9B64042EAA240", x"5570530829705592", x"8638809E878787A0",
     x"41B9A79AF79AC208", x"7A9BE42F2009A892", x"29038D56BA6D2745",
     x"5495C6ABF1E5DF51", x"AE13DBD561488933", x"024D1FFA8904E389",
     x"D1399712F99BF02E", x"14C1D7C1CFFEC79E", x"1DE5279DAE3BED6F",
     x"E941A33F85501303", x"DA99DBBC9A03F379", x"B7FC92F91D8E92E9",
     x"AE8E5CAA3CA04E85", x"9CC62DF43B6EED74", x"D863DBB5C59A91A0",
     x"A1AB2190545B91D7", x"0875041E64C570F7", x"5A594528BEBEF1CC",
     x"FCDB3291DE21F0C0", x"869EFD7F9F265A09");


  signal s_clk      : std_logic := '0';
  signal s_mode     : std_logic := '0';
  signal s_key      : std_logic_vector(0 to 63) := (others => '0');
  signal s_datain   : std_logic_vector(0 to 63) := (others => '0');
  signal s_validin  : std_logic := '0';
  signal s_dataout  : std_logic_vector(0 to 63);
  signal s_validout : std_logic;


  component des is
    port (
      clk_i       : in  std_logic;
      mode_i      : in  std_logic;
      key_i       : in  std_logic_vector(0 TO 63);
      data_i      : in  std_logic_vector(0 TO 63);
      valid_i     : in  std_logic;
      data_o      : out std_logic_vector(0 TO 63);
      valid_o     : out std_logic
    );
  end component des;


begin


  s_clk <= not(s_clk) after 10 ns;
  
  
  teststimuliP : process is
  begin
    s_mode    <= '0';
    s_validin <= '0';
    s_key     <= x"0101010101010101";
    s_datain  <= x"8000000000000000";
    -- Variable plaintext known answer test
    -- Encryption
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk);
        s_validin <= '1';
        if(index /= 0) then
          s_datain <= '0' & s_datain(0 to 62);
        end if;
    end loop;
    wait until rising_edge(s_clk);
    s_mode    <= '0';
    s_validin <= '0';
    s_key     <= (others => '0');
    s_datain  <= (others => '0');
    wait for 100 ns;
    -- Inverse permutation known answer test
    -- Encryption
    s_key     <= x"0101010101010101";
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk);
        s_validin <= '1';
        s_datain  <= s_variable_plaintext_known_answers(index);
    end loop;
    wait until rising_edge(s_clk);
    s_mode    <= '0';
    s_validin <= '0';
    s_key     <= (others => '0');
    s_datain  <= (others => '0');
    wait for 100 ns;
    -- Variable key known answer test
    -- Encryption
    s_key     <= x"8000000000000000";
    for index in s_variable_key_known_answers'range loop
      wait until rising_edge(s_clk);
        s_validin <= '1';
        if(index /= 0) then
          if(index = 7 or index = 14 or index = 21 or index = 28 or index = 35 or
             index = 42 or index = 49) then
            s_key <= "00" & s_key(0 to 61);
          else
            s_key <= '0' & s_key(0 to 62);
          end if;
        end if;
    end loop;
    wait until rising_edge(s_clk);
    s_mode    <= '0';
    s_validin <= '0';
    s_key     <= (others => '0');
    s_datain  <= (others => '0');
    wait for 100 ns;

    -- Variable plaintext known answer test
    -- Decryption
    s_key     <= x"0101010101010101";
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk);
        s_mode    <= '1';
        s_validin <= '1';
        s_datain  <= s_variable_plaintext_known_answers(index);
    end loop;
    wait until rising_edge(s_clk);
    s_mode    <= '0';
    s_validin <= '0';
    s_key     <= (others => '0');
    s_datain  <= (others => '0');
    wait;
  end process teststimuliP;
  
  
  testcheckerP : process is
    variable v_plaintext : std_logic_vector(0 to 63) := x"8000000000000000";
  begin
    report "# Variable plaintext known answer test";
    report "# Encryption";
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk) and s_validout = '1';
        assert (s_dataout = s_variable_plaintext_known_answers(index))
          report "encryption error"
          severity error;
    end loop;
    report "# Inverse permutation known answer test";
    report "# Encryption";
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk) and s_validout = '1';
        assert (s_dataout = v_plaintext)
          report "encryption error"
          severity error;
        v_plaintext := '0' & v_plaintext(0 to 62);
    end loop;
    report "# Variable key known answer test";
    report "# Encryption";
    for index in s_variable_key_known_answers'range loop
      wait until rising_edge(s_clk) and s_validout = '1';
        assert (s_dataout = s_variable_key_known_answers(index))
          report "encryption error"
          severity error;
    end loop;

    report "# Variable plaintext known answer test";
    report "# Decryption";
    v_plaintext := x"8000000000000000";
    for index in s_variable_plaintext_known_answers'range loop
      wait until rising_edge(s_clk) and s_validout = '1';
        assert (s_dataout = v_plaintext) 
          report "decryption error"
          severity error;
        v_plaintext := '0' & v_plaintext(0 to 62);
    end loop;
    report "# Successfully passed all tests";
    wait;
  end process testcheckerP;


  i_des : des
  port map (
    clk_i    => s_clk,
    mode_i   => s_mode,
    key_i    => s_key,
    data_i   => s_datain,
    valid_i  => s_validin,               
    data_o   => s_dataout,
    valid_o  => s_validout
  );


end architecture rtl;
