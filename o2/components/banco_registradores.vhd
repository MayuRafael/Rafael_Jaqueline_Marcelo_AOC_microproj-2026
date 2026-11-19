library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_registradores is
    port (
        clk           : in  std_logic;
        escreve       : in  std_logic;
        reg_leitura1  : in  std_logic_vector(4 downto 0);
        reg_leitura2  : in  std_logic_vector(4 downto 0);
        reg_escrita   : in  std_logic_vector(4 downto 0);
        dado_escrita  : in  std_logic_vector(31 downto 0);
        dado_leitura1 : out std_logic_vector(31 downto 0);
        dado_leitura2 : out std_logic_vector(31 downto 0);
        dbg_reg_addr  : in  std_logic_vector(4 downto 0);
        dbg_reg_data  : out std_logic_vector(31 downto 0)
    );
end entity banco_registradores;

architecture comportamento of banco_registradores is

    type banco_t is array (0 to 31) of
        std_logic_vector(31 downto 0);

    signal registradores : banco_t :=
        (others => (others => '0'));

begin

       process(clk)
    begin
if falling_edge(clk) then
            if escreve = '1' and
               not is_x(reg_escrita) and
               reg_escrita /= "00000" then

                registradores(to_integer(unsigned(reg_escrita)))
                    <= dado_escrita;
            end if;
        end if;
    end process;

    dado_leitura1 <= (others => '0')
        when is_x(reg_leitura1) or reg_leitura1 = "00000"
        else registradores(to_integer(unsigned(reg_leitura1)));

    dado_leitura2 <= (others => '0')
        when is_x(reg_leitura2) or reg_leitura2 = "00000"
        else registradores(to_integer(unsigned(reg_leitura2)));

    dbg_reg_data <= (others => '0')
        when is_x(dbg_reg_addr) or dbg_reg_addr = "00000"
        else registradores(to_integer(unsigned(dbg_reg_addr)));
end architecture comportamento;