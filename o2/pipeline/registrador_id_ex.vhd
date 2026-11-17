
library ieee;
use ieee.std_logic_1164.all;

entity registrador_id_ex is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        habilita : in std_logic;

        -- Dados de entrada
        pc_entrada        : in std_logic_vector(31 downto 0);
        dado1_entrada     : in std_logic_vector(31 downto 0);
        dado2_entrada     : in std_logic_vector(31 downto 0);
        imediato_entrada  : in std_logic_vector(31 downto 0);

        rs_entrada        : in std_logic_vector(4 downto 0);
        rt_entrada        : in std_logic_vector(4 downto 0);
        rd_entrada        : in std_logic_vector(4 downto 0);

        valid_entrada     : in std_logic;

        -- Sinais de controle
        reg_dst_entrada   : in std_logic;
        alu_src_entrada   : in std_logic;
        alu_op_entrada    : in std_logic_vector(2 downto 0);

        branch_entrada    : in std_logic;
        mem_read_entrada  : in std_logic;
        mem_write_entrada : in std_logic;

        reg_write_entrada : in std_logic;
        mem_para_reg_entrada : in std_logic;

        -- Dados de saída
        pc_saida        : out std_logic_vector(31 downto 0);
        dado1_saida     : out std_logic_vector(31 downto 0);
        dado2_saida     : out std_logic_vector(31 downto 0);
        imediato_saida  : out std_logic_vector(31 downto 0);

        rs_saida        : out std_logic_vector(4 downto 0);
        rt_saida        : out std_logic_vector(4 downto 0);
        rd_saida        : out std_logic_vector(4 downto 0);

        valid_saida     : out std_logic;

        -- Sinais de controle de saída
        reg_dst_saida   : out std_logic;
        alu_src_saida   : out std_logic;
        alu_op_saida    : out std_logic_vector(2 downto 0);

        branch_saida    : out std_logic;
        mem_read_saida  : out std_logic;
        mem_write_saida : out std_logic;

        reg_write_saida : out std_logic;
        mem_para_reg_saida : out std_logic
    );
end entity registrador_id_ex;

architecture comportamento of registrador_id_ex is
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_saida <= (others => '0');
                dado1_saida <= (others => '0');
                dado2_saida <= (others => '0');
                imediato_saida <= (others => '0');

                rs_saida <= (others => '0');
                rt_saida <= (others => '0');
                rd_saida <= (others => '0');

                valid_saida <= '0';

                reg_dst_saida <= '0';
                alu_src_saida <= '0';
                alu_op_saida <= (others => '0');

                branch_saida <= '0';
                mem_read_saida <= '0';
                mem_write_saida <= '0';

                reg_write_saida <= '0';
                mem_para_reg_saida <= '0';

            elsif habilita = '1' then

                -- Armazenamento dos dados
                pc_saida <= pc_entrada;
                dado1_saida <= dado1_entrada;
                dado2_saida <= dado2_entrada;
                imediato_saida <= imediato_entrada;

                rs_saida <= rs_entrada;
                rt_saida <= rt_entrada;
                rd_saida <= rd_entrada;

                -- Armazenamento dos controles
                reg_dst_saida <= reg_dst_entrada;
                alu_src_saida <= alu_src_entrada;
                alu_op_saida <= alu_op_entrada;

                branch_saida <= branch_entrada;
                mem_read_saida <= mem_read_entrada;
                mem_write_saida <= mem_write_entrada;

                reg_write_saida <= reg_write_entrada;
                mem_para_reg_saida <= mem_para_reg_entrada;

                valid_saida <= valid_entrada;
            end if;
        end if;
    end process;

end architecture comportamento;
