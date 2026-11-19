
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_memoria_unificada is
end entity;

architecture teste of tb_memoria_unificada is

    signal clk          : std_logic := '0';
    signal endereco_if  : std_logic_vector(31 downto 0) := (others => '0');
    signal instrucao    : std_logic_vector(31 downto 0);

    signal endereco_mem : std_logic_vector(31 downto 0) := (others => '0');
    signal dado_escrita : std_logic_vector(31 downto 0) := (others => '0');
    signal escreve      : std_logic := '0';
    signal dado_leitura : std_logic_vector(31 downto 0);

begin

    -- Geração do clock
    clk <= not clk after 5 ns;

    -- Instância da memória unificada
    memoria: entity work.memoria_unificada
        generic map (
            PROG_FILE => ""
        )
        port map (
            clk          => clk,
            endereco_if  => endereco_if,
            instrucao    => instrucao,
            endereco_mem => endereco_mem,
            dado_escrita => dado_escrita,
            escreve      => escreve,
            dado_leitura => dado_leitura
        );

    process
    begin

        -- Escolhe o endereço 4
        endereco_if  <= x"00000004";
        endereco_mem <= x"00000004";

        -- Prepara a escrita pelo estágio MEM
        dado_escrita <= x"12345678";
        escreve <= '1';

        -- Aguarda a escrita acontecer
        wait until rising_edge(clk);
        wait for 1 ns;

        -- Desativa a escrita
        escreve <= '0';
        wait for 1 ns;

        -- Verifica a leitura pelo IF
        assert instrucao = x"12345678"
            report "ERRO: IF nao encontrou o dado escrito"
            severity failure;

        -- Verifica a leitura pelo MEM
        assert dado_leitura = x"12345678"
            report "ERRO: MEM nao encontrou o dado escrito"
            severity failure;

        report "SUCESSO: memoria compartilhada funcionando!"
            severity note;

        stop;
        wait;

    end process;

end architecture teste;
