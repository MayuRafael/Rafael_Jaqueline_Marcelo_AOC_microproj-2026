
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port (
        operacao : in  std_logic_vector(2 downto 0);
        entrada1 : in  std_logic_vector(31 downto 0);
        entrada2 : in  std_logic_vector(31 downto 0);
        resultado : out std_logic_vector(31 downto 0);
        zero : out std_logic
    );
end entity ula;

architecture comportamento of ula is
    signal resultado_interno : std_logic_vector(31 downto 0);
begin

    process(operacao, entrada1, entrada2)
    begin
        case operacao is

            when "000" =>
                resultado_interno <= std_logic_vector(
                    signed(entrada1) + signed(entrada2));

            when "001" =>
                resultado_interno <= std_logic_vector(
                    signed(entrada1) - signed(entrada2));

            when "010" =>
                resultado_interno <= entrada1 and entrada2;

            when "011" =>
                resultado_interno <= entrada1 or entrada2;

            when "100" =>
                if signed(entrada1) < signed(entrada2) then
                    resultado_interno <=
                        x"00000001";
                else
                    resultado_interno <=
                        x"00000000";
                end if;

            when others =>
                resultado_interno <= (others => '0');

        end case;
    end process;

    resultado <= resultado_interno;

    zero <= '1' when resultado_interno =
        x"00000000" else '0';

end architecture comportamento;
