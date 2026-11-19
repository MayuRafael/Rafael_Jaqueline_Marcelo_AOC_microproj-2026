
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity memoria_instrucao is
    generic (
        PROG_FILE : string := ""
    );
    port (
        endereco  : in  std_logic_vector(31 downto 0);
        instrucao : out std_logic_vector(31 downto 0)
    );
end entity memoria_instrucao;

architecture comportamento of memoria_instrucao is

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

    constant memoria : memoria_t := carregar_memoria;

begin

   process(all)
begin
    if is_x(endereco(9 downto 2)) then
        instrucao <= (others => '0');
    else
        instrucao <= memoria(to_integer(unsigned(endereco(9 downto 2))));
    end if;
end process;

end architecture comportamento;
