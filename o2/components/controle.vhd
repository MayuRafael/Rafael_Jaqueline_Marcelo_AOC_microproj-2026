
library ieee;
use ieee.std_logic_1164.all;

entity controle is
    port (
        opcode    : in  std_logic_vector(5 downto 0);
        funct     : in  std_logic_vector(5 downto 0);
        reg_dst   : out std_logic;
        alu_src   : out std_logic;
        mem_para_reg : out std_logic;
        reg_escreve : out std_logic;
        mem_le     : out std_logic;
        mem_escreve : out std_logic;
        branch    : out std_logic;
        alu_op    : out std_logic_vector(2 downto 0);
        halt      : out std_logic
    );
end entity controle;

architecture comportamento of controle is
begin

    process(opcode, funct)
    begin
        reg_dst      <= '0';
        alu_src      <= '0';
        mem_para_reg <= '0';
        reg_escreve  <= '0';
        mem_le       <= '0';
        mem_escreve  <= '0';
        branch       <= '0';
        alu_op       <= "000";
        halt         <= '0';

        case opcode is

            -- Instruções tipo R
            when "000000" =>
                reg_dst     <= '1';
                reg_escreve <= '1';

                case funct is
                    when "100000" => alu_op <= "000"; -- add
                    when "100010" => alu_op <= "001"; -- sub
                    when "100100" => alu_op <= "010"; -- and
                    when "100101" => alu_op <= "011"; -- or
                    when "101010" => alu_op <= "100"; -- slt
                    when "001101" =>
                        reg_escreve <= '0';
                        halt <= '1'; -- break
                    when others =>
                        reg_escreve <= '0';
                end case;

            -- addi
            when "001000" =>
                alu_src     <= '1';
                reg_escreve <= '1';
                alu_op      <= "000";

            -- lw
            when "100011" =>
                alu_src      <= '1';
                mem_para_reg <= '1';
                reg_escreve  <= '1';
                mem_le       <= '1';
                alu_op       <= "000";

            -- sw
            when "101011" =>
                alu_src     <= '1';
                mem_escreve <= '1';
                alu_op      <= "000";

            -- beq
            when "000100" =>
                branch <= '1';
                alu_op <= "001";

            when others =>
                null;

        end case;
    end process;

end architecture comportamento;
