
library ieee;
use ieee.std_logic_1164.all;

entity registrador_if_id is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        habilita  : in std_logic;

        pc_entrada        : in std_logic_vector(31 downto 0);
        instrucao_entrada : in std_logic_vector(31 downto 0);
        valid_entrada     : in std_logic;

        pc_saida        : out std_logic_vector(31 downto 0);
        instrucao_saida : out std_logic_vector(31 downto 0);
        valid_saida     : out std_logic
    );
end entity;

architecture comportamento of registrador_if_id is
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                valid_saida <= '0';

            elsif habilita = '1' then
                pc_saida        <= pc_entrada;
                instrucao_saida <= instrucao_entrada;
                valid_saida     <= valid_entrada;
            end if;
        end if;
    end process;

end architecture;
