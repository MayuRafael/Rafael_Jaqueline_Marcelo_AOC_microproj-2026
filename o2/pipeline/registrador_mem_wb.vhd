library ieee;
use ieee.std_logic_1164.all;

entity registrador_mem_wb is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        habilita : in std_logic;

        -- Dados de entrada
        dado_memoria_entrada : in std_logic_vector(31 downto 0);
        resultado_ula_entrada : in std_logic_vector(31 downto 0);
        registrador_destino_entrada : in std_logic_vector(4 downto 0);

        -- Sinais de controle
        reg_write_entrada    : in std_logic;
        mem_para_reg_entrada : in std_logic;

        valid_entrada : in std_logic;

        -- Dados de saída
        dado_memoria_saida : out std_logic_vector(31 downto 0);
        resultado_ula_saida : out std_logic_vector(31 downto 0);
        registrador_destino_saida : out std_logic_vector(4 downto 0);

        -- Sinais de controle de saída
        reg_write_saida    : out std_logic;
        mem_para_reg_saida : out std_logic;

        valid_saida : out std_logic
    );
end entity;

architecture comportamento of registrador_mem_wb is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                valid_saida <= '0';

            elsif habilita = '1' then
                -- Armazenamento dos dados
                dado_memoria_saida <= dado_memoria_entrada;
                resultado_ula_saida <= resultado_ula_entrada;
                registrador_destino_saida <= registrador_destino_entrada;

                -- Armazenamento dos controles
                reg_write_saida <= reg_write_entrada;
                mem_para_reg_saida <= mem_para_reg_entrada;

                valid_saida <= valid_entrada;
            end if;
        end if;
    end process;
end architecture;