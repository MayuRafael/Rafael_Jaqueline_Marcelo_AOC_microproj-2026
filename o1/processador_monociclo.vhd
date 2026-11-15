
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
    generic (
        PROG_FILE     : string := "";
        MEM_UNIFICADA : boolean := false
    );
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        done         : out std_logic;
        hazard_abort : out std_logic;
        hazard_type  : out std_logic_vector(1 downto 0);
        hazard_pc    : out std_logic_vector(31 downto 0);
        hazard_cycle : out unsigned(31 downto 0);
        retired      : out unsigned(1 downto 0);
        stage_valid  : out std_logic_vector(9 downto 0);
        dbg_reg_addr : in  std_logic_vector(4 downto 0);
        dbg_reg_data : out std_logic_vector(31 downto 0)
    );
end entity cpu_top;

architecture estrutural of cpu_top is

    signal pc_atual       : std_logic_vector(31 downto 0);
    signal pc_destino     : std_logic_vector(31 downto 0);
    signal instrucao      : std_logic_vector(31 downto 0);

    signal reg_dst        : std_logic;
    signal alu_src        : std_logic;
    signal mem_para_reg   : std_logic;
    signal reg_escreve    : std_logic;
    signal mem_le         : std_logic;
    signal mem_escreve    : std_logic;
    signal branch         : std_logic;
    signal alu_op         : std_logic_vector(2 downto 0);
    signal halt_s         : std_logic;

    signal dado_reg1      : std_logic_vector(31 downto 0);
    signal dado_reg2      : std_logic_vector(31 downto 0);
    signal reg_destino    : std_logic_vector(4 downto 0);
    signal dado_ula2      : std_logic_vector(31 downto 0);
    signal resultado_ula  : std_logic_vector(31 downto 0);
    signal zero_ula       : std_logic;

    signal imediato      : std_logic_vector(31 downto 0);
    signal dado_memoria  : std_logic_vector(31 downto 0);
    signal dado_escrita  : std_logic_vector(31 downto 0);

    signal desvio_real   : std_logic;
    signal habilita_pc   : std_logic;

begin

    -- Contador de programa
    U_PC: entity work.pc
        port map (
            clk              => clk,
            rst              => rst,
            habilita         => habilita_pc,
            desvio           => desvio_real,
            endereco_destino => pc_destino,
            endereco         => pc_atual
        );

    -- Memoria de instrucoes
    U_MEM_INST: entity work.memoria_instrucao
        generic map (
            PROG_FILE => PROG_FILE
        )
        port map (
            endereco  => pc_atual,
            instrucao => instrucao
        );

    -- Unidade de controle
    U_CONTROLE: entity work.controle
        port map (
            opcode       => instrucao(31 downto 26),
            funct        => instrucao(5 downto 0),
            reg_dst      => reg_dst,
            alu_src      => alu_src,
            mem_para_reg => mem_para_reg,
            reg_escreve  => reg_escreve,
            mem_le       => mem_le,
            mem_escreve  => mem_escreve,
            branch       => branch,
            alu_op       => alu_op,
            halt         => halt_s
        );

    -- Banco de registradores
    reg_destino <= instrucao(15 downto 11)
        when reg_dst = '1'
        else instrucao(20 downto 16);

    U_BANCO: entity work.banco_registradores
        port map (
            clk           => clk,
            escreve       => reg_escreve,
            reg_leitura1  => instrucao(25 downto 21),
            reg_leitura2  => instrucao(20 downto 16),
            reg_escrita   => reg_destino,
            dado_escrita  => dado_escrita,
            dado_leitura1 => dado_reg1,
            dado_leitura2 => dado_reg2,
            dbg_reg_addr  => dbg_reg_addr,
            dbg_reg_data  => dbg_reg_data
        );

    -- Extensao de sinal do imediato
    imediato <= std_logic_vector(
        resize(signed(instrucao(15 downto 0)), 32)
    );

    -- Seletor do segundo operando da ULA
    dado_ula2 <= imediato
        when alu_src = '1'
        else dado_reg2;

    -- Unidade logica e aritmetica
    U_ULA: entity work.ula
        port map (
            operacao  => alu_op,
            entrada1  => dado_reg1,
            entrada2  => dado_ula2,
            resultado => resultado_ula,
            zero      => zero_ula
        );

    -- Memoria de dados
    U_MEM_DADOS: entity work.memoria_dados
        port map (
            clk          => clk,
            escreve      => mem_escreve,
            endereco     => resultado_ula,
            dado_escrita => dado_reg2,
            dado_leitura => dado_memoria
        );

    -- Selecao do dado que sera escrito no banco
    dado_escrita <= dado_memoria
        when mem_para_reg = '1'
        else resultado_ula;

    -- Calculo do endereco de desvio do BEQ
    pc_destino <= std_logic_vector(
        unsigned(pc_atual) + 4 +
        unsigned(shift_left(signed(imediato), 2))
    );

    desvio_real <= branch and zero_ula;

    -- Sinal de conclusao
done <= halt_s;
habilita_pc <= not halt_s;
    hazard_abort <= '0';
    hazard_type  <= "00";
    hazard_pc    <= (others => '0');
    hazard_cycle <= (others => '0');
        process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                retired    <= "00";
                stage_valid <= (others => '0');
            else
                if halt_s = '1' then
                    retired    <= "00";
                    stage_valid <= (others => '0');
                else
                    retired    <= "01";
                    stage_valid <= "0000000001";
                end if;
            end if;
        end if;
    end process;
end architecture estrutural;
