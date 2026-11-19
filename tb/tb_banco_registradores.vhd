
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_banco_registradores is
end entity;

architecture teste of tb_banco_registradores is

    signal clk           : std_logic := '0';
    signal escreve       : std_logic := '0';
    signal reg_leitura1  : std_logic_vector(4 downto 0) := "00000";
    signal reg_leitura2  : std_logic_vector(4 downto 0) := "00000";
    signal reg_escrita   : std_logic_vector(4 downto 0) := "00000";
    signal dado_escrita  : std_logic_vector(31 downto 0) := (others => '0');
    signal dado_leitura1 : std_logic_vector(31 downto 0);
    signal dado_leitura2 : std_logic_vector(31 downto 0);
    signal dbg_reg_addr  : std_logic_vector(4 downto 0) := "00000";
    signal dbg_reg_data  : std_logic_vector(31 downto 0);

begin

    clk <= not clk after 5 ns;

    uut: entity work.banco_registradores
        port map (
            clk           => clk,
            escreve       => escreve,
            reg_leitura1  => reg_leitura1,
            reg_leitura2  => reg_leitura2,
            reg_escrita   => reg_escrita,
            dado_escrita  => dado_escrita,
            dado_leitura1 => dado_leitura1,
            dado_leitura2 => dado_leitura2,
            dbg_reg_addr  => dbg_reg_addr,
            dbg_reg_data  => dbg_reg_data
        );

    process
    begin
        -- Escreve 42 no registrador 8.
        reg_escrita  <= "01000";
        dado_escrita <= x"0000002A";
        escreve      <= '1';

        wait until falling_edge(clk);
        wait for 1 ns;

        -- Confere as duas portas de leitura e a porta de depuração.
        reg_leitura1 <= "01000";
        reg_leitura2 <= "01000";
        dbg_reg_addr <= "01000";

        wait for 1 ns;

        assert dado_leitura1 = x"0000002A"
            report "ERRO: leitura 1 incorreta"
            severity failure;

        assert dado_leitura2 = x"0000002A"
            report "ERRO: leitura 2 incorreta"
            severity failure;

        assert dbg_reg_data = x"0000002A"
            report "ERRO: leitura de depuracao incorreta"
            severity failure;

        -- Confere que o registrador zero não pode ser alterado.
        reg_escrita  <= "00000";
        dado_escrita <= x"FFFFFFFF";

        wait until falling_edge(clk);
        wait for 1 ns;

        reg_leitura1 <= "00000";
        wait for 1 ns;

        assert dado_leitura1 = x"00000000"
            report "ERRO: registrador zero foi alterado"
            severity failure;

        report "SUCESSO: banco de registradores funcionando!"
            severity note;

        wait;
    end process;

end architecture;
