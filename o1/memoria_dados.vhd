library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_dados is
    port (
        clk          : in  std_logic;
        escreve      : in  std_logic;
        endereco     : in  std_logic_vector(31 downto 0);
        dado_escrita : in  std_logic_vector(31 downto 0);
        dado_leitura : out std_logic_vector(31 downto 0)
    );
end entity memoria_dados;

architecture comportamento of memoria_dados is
    type memoria_t is array (0 to 255) of
        std_logic_vector(31 downto 0);

    signal memoria : memoria_t :=
        (others => (others => '0'));

    signal indice : natural range 0 to 255;
begin
    process(all)
begin
    if is_x(endereco(9 downto 2)) then
        indice <= 0;
    else
        indice <= to_integer(unsigned(endereco(9 downto 2)));
    end if;
end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if escreve = '1' then
                memoria(indice) <= dado_escrita;
            end if;
        end if;
    end process;

    dado_leitura <= memoria(indice);
end architecture comportamento;