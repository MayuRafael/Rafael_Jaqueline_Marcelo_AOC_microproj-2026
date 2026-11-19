
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_pipeline is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        habilita         : in  std_logic;
        hazard_abort     : in  std_logic;
        desvio           : in  std_logic;
        endereco_destino : in  std_logic_vector(31 downto 0);
        endereco         : out std_logic_vector(31 downto 0)
    );
end entity pc_pipeline;

architecture comportamento of pc_pipeline is
    signal pc_atual : unsigned(31 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_atual <= (others => '0');

            elsif habilita = '1' and hazard_abort = '0' then
                if desvio = '1' then
                    pc_atual <= unsigned(endereco_destino);
                else
                    pc_atual <= pc_atual + 4;
                end if;
            end if;
        end if;
    end process;

    endereco <= std_logic_vector(pc_atual);

end architecture comportamento;
