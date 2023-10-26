library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal ext_de_signe:  std_logic;
    signal x,y: signed(32 downto 0);
    signal z: std_logic;
    signal s: signed(32 downto 0);
    signal nul: unsigned(32 downto 0);
begin
    ext_de_signe <= (not IR(12) and not IR(6)) or (IR(6) and not IR(13));
    x <= signed((ext_de_signe and rs1(31)) & rs1 );
    y <= signed((ext_de_signe and alu_y(31)) & alu_y );
    s <= x - y;
    slt <= s(32);
    z <= nor s;
    jcond <= ((s(32) xor IR(12)) and IR(14)) or ((z xor IR(12)) and (not IR(14)));
end architecture;
