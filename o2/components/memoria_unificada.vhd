
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity memoria_unificada is
    generic (
        PROG_FILE : string := ""
    );
    port (
        clk          : in  std_logic;

        -- Acesso do estágio IF
        endereco_if  : in  std_logic_vector(31 downto 0);
        instrucao    : out std_logic_vector(31 downto 0);

        -- Acesso do estágio MEM
        endereco_mem : in  std_logic_vector(31 downto 0);
        dado_escrita : in  std_logic_vector(31 downto 0);
        escreve      : in  std_logic;
        dado_leitura : out std_logic_vector(31 downto 0)
    );
end entity memoria_unificada;

architecture comportamento of memoria_unificada is

    type memoria_t is array (0 to 255) of
        std_logic_vector(31 downto 0);

    impure function carregar_memoria return memoria_t is
        file arquivo : text;
        variable status : file_open_status;
        variable linha : line;
        variable dados : std_logic_vector(31 downto 0);
        variable resultado : memoria_t :=
            (others => (others => '0'));
        variable i : natural := 0;
    begin
        if PROG_FILE /= "" then
            file_open(status, arquivo, PROG_FILE, read_mode);

            assert status = open_ok
                report "Erro ao abrir arquivo HEX: " & PROG_FILE
                severity failure;

            while not endfile(arquivo) and i < 256 loop
                readline(arquivo, linha);
                hread(linha, dados);
                resultado(i) := dados;
                i := i + 1;
            end loop;

            file_close(arquivo);
        end if;

        return resultado;
    end function;

    signal memoria : memoria_t := carregar_memoria;

    signal indice_if  : natural range 0 to 255;
    signal indice_mem : natural range 0 to 255;

begin

    -- Endereço de busca de instrução
    process(all)
    begin
        if is_x(endereco_if(9 downto 2)) then
            indice_if <= 0;
        else
            indice_if <= to_integer(unsigned(endereco_if(9 downto 2)));
        end if;
    end process;

    -- Endereço de acesso aos dados
    process(all)
    begin
        if is_x(endereco_mem(9 downto 2)) then
            indice_mem <= 0;
        else
            indice_mem <= to_integer(unsigned(endereco_mem(9 downto 2)));
        end if;
    end process;

    -- Leitura de instrução pelo IF
    instrucao <= memoria(indice_if);

    -- Leitura de dados pelo MEM
    dado_leitura <= memoria(indice_mem);

    -- Escrita de dados pelo MEM
    process(clk)
    begin
        if rising_edge(clk) then
            if escreve = '1' then
                memoria(indice_mem) <= dado_escrita;
            end if;
        end if;
    end process;

end architecture comportamento;
