library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
    generic (
        PROG_FILE     : string  := "";
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

architecture comportamento of cpu_top is

    -- CONTROLE GERAL
    signal contador_ciclos : unsigned(31 downto 0) := (others => '0');
    signal abort_reg       : std_logic := '0';
    signal tipo_abort_reg  : std_logic_vector(1 downto 0) := "00";
    signal pc_abort_reg    : std_logic_vector(31 downto 0) := (others => '0');
    signal ciclo_abort_reg : unsigned(31 downto 0) := (others => '0');

    signal stop_fetch       : std_logic := '0';
    signal habilita_pipeline : std_logic;
    signal detecta_hazard   : std_logic;
    signal tipo_hazard_comb : std_logic_vector(1 downto 0);
    signal pc_hazard_comb   : std_logic_vector(31 downto 0);

    -- ESTAGIO IF
    signal pc_atual         : std_logic_vector(31 downto 0);
    signal instrucao_if     : std_logic_vector(31 downto 0);
    signal valid_if_entrada : std_logic;

    -- REGISTRADOR IF/ID
    signal pc_if_id     : std_logic_vector(31 downto 0);
    signal instrucao_id : std_logic_vector(31 downto 0);
    signal valid_if_id  : std_logic;

    -- ESTAGIO ID
    signal dado1_id    : std_logic_vector(31 downto 0);
    signal dado2_id    : std_logic_vector(31 downto 0);
    signal imediato_id : std_logic_vector(31 downto 0);

    signal reg_dst_id      : std_logic;
    signal alu_src_id      : std_logic;
    signal mem_para_reg_id : std_logic;
    signal reg_escreve_id  : std_logic;
    signal mem_le_id       : std_logic;
    signal mem_escreve_id  : std_logic;
    signal branch_id       : std_logic;
    signal alu_op_id       : std_logic_vector(2 downto 0);
    signal halt_id         : std_logic;

    signal reg_escrita_wb  : std_logic_vector(4 downto 0);
    signal dado_escrita_wb : std_logic_vector(31 downto 0);
    signal reg_escreve_wb  : std_logic;

    -- REGISTRADOR ID/EX
    signal pc_id_ex       : std_logic_vector(31 downto 0);
    signal dado1_id_ex    : std_logic_vector(31 downto 0);
    signal dado2_id_ex    : std_logic_vector(31 downto 0);
    signal imediato_id_ex : std_logic_vector(31 downto 0);

    signal rs_id_ex : std_logic_vector(4 downto 0);
    signal rt_id_ex : std_logic_vector(4 downto 0);
    signal rd_id_ex : std_logic_vector(4 downto 0);

    signal valid_id_ex        : std_logic;
    signal valid_id_ex_entrada : std_logic;

    signal reg_dst_id_ex      : std_logic;
    signal alu_src_id_ex      : std_logic;
    signal alu_op_id_ex       : std_logic_vector(2 downto 0);
    signal branch_id_ex       : std_logic;
    signal mem_read_id_ex     : std_logic;
    signal mem_write_id_ex    : std_logic;
    signal reg_write_id_ex    : std_logic;
    signal mem_para_reg_id_ex : std_logic;

    -- ESTAGIO EX
    signal entrada2_ula  : std_logic_vector(31 downto 0);
    signal resultado_ula : std_logic_vector(31 downto 0);
    signal zero_ula      : std_logic;

    signal destino_ex      : std_logic_vector(4 downto 0);
    signal branch_taken    : std_logic;
    signal endereco_desvio : std_logic_vector(31 downto 0);

    -- REGISTRADOR EX/MEM
    signal resultado_ex_mem     : std_logic_vector(31 downto 0);
    signal dado_memoria_ex_mem  : std_logic_vector(31 downto 0);
    signal destino_ex_mem       : std_logic_vector(4 downto 0);
    signal valid_ex_mem         : std_logic;

    signal mem_read_ex_mem     : std_logic;
    signal mem_write_ex_mem    : std_logic;
    signal reg_write_ex_mem    : std_logic;
    signal mem_para_reg_ex_mem : std_logic;

    -- ESTAGIO MEM
    signal dado_lido_mem : std_logic_vector(31 downto 0);

    -- REGISTRADOR MEM/WB
    signal dado_mem_wb       : std_logic_vector(31 downto 0);
    signal resultado_mem_wb  : std_logic_vector(31 downto 0);
    signal destino_mem_wb    : std_logic_vector(4 downto 0);
    signal valid_mem_wb      : std_logic;

    signal reg_write_mem_wb    : std_logic;
    signal mem_para_reg_mem_wb : std_logic;

begin

    --------------------------------------------------------------------
    -- CONTROLE GERAL E REGISTRO DO ABORTO
    --------------------------------------------------------------------

    -- Ao detectar um hazard, o pipeline inteiro deixa de avançar.
    habilita_pipeline <= '1'
        when abort_reg = '0' and detecta_hazard = '0' and rst = '0'
        else '0';

        hazard_abort <= '1' when abort_reg = '1' else
                    '1' when detecta_hazard = '1' else
                    '0';

        hazard_type  <= tipo_abort_reg when abort_reg = '1' else
                        tipo_hazard_comb when detecta_hazard = '1' else
                        "00";

        hazard_pc    <= pc_abort_reg when abort_reg = '1' else
                        pc_hazard_comb when detecta_hazard = '1' else
                        (others => '0');

        hazard_cycle <= ciclo_abort_reg when abort_reg = '1' else
                        contador_ciclos + 1 when detecta_hazard = '1' else
                        (others => '0');
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                contador_ciclos <= (others => '0');
                abort_reg       <= '0';
                tipo_abort_reg  <= "00";
                pc_abort_reg    <= (others => '0');
                ciclo_abort_reg <= (others => '0');
            else
                if abort_reg = '0' then
                    contador_ciclos <= contador_ciclos + 1;

                    if detecta_hazard = '1' then
                        abort_reg       <= '1';
                        tipo_abort_reg  <= tipo_hazard_comb;
                        pc_abort_reg    <= pc_hazard_comb;
                        ciclo_abort_reg <= contador_ciclos + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- PARADA DA BUSCA AO ENCONTRAR BREAK
    --------------------------------------------------------------------

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                stop_fetch <= '0';
            elsif habilita_pipeline = '1' then
                if valid_if_id = '1' and halt_id = '1' then
                    stop_fetch <= '1';
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- ESTAGIO IF: PC
    --------------------------------------------------------------------

    pc_instancia : entity work.pc_pipeline
        port map (
            clk              => clk,
            rst              => rst,
            habilita         => habilita_pipeline and
                                not stop_fetch and
                                not (valid_if_id and halt_id),
            hazard_abort     => abort_reg or detecta_hazard,
            desvio           => branch_taken,
            endereco_destino => endereco_desvio,
            endereco         => pc_atual
        );

    --------------------------------------------------------------------
    -- MEMORIAS DE INSTRUCOES E DADOS
    --------------------------------------------------------------------

    memoria_unificada_gen : if MEM_UNIFICADA generate

        memoria_unificada_instancia : entity work.memoria_unificada
            generic map (
                PROG_FILE => PROG_FILE
            )
            port map (
                clk          => clk,
                endereco_if  => pc_atual,
                instrucao    => instrucao_if,
                endereco_mem => resultado_ex_mem,
                dado_escrita => dado_memoria_ex_mem,
                escreve      => valid_ex_mem and
                                mem_write_ex_mem and
                                habilita_pipeline,
                dado_leitura => dado_lido_mem
            );

    end generate;

    memoria_separada_gen : if not MEM_UNIFICADA generate

        memoria_instrucao_instancia : entity work.memoria_instrucao
            generic map (
                PROG_FILE => PROG_FILE
            )
            port map (
                endereco  => pc_atual,
                instrucao => instrucao_if
            );

        memoria_dados_instancia : entity work.memoria_dados
            port map (
                clk          => clk,
                escreve      => valid_ex_mem and
                                mem_write_ex_mem and
                                habilita_pipeline,
                endereco     => resultado_ex_mem,
                dado_escrita => dado_memoria_ex_mem,
                dado_leitura => dado_lido_mem
            );

    end generate;

    -- IF só contém instrução válida se a palavra não for zero e a busca
    -- não tiver sido encerrada por BREAK.
    valid_if_entrada <= '1'
        when instrucao_if /= x"00000000" and
             stop_fetch = '0' and
             not (valid_if_id = '1' and halt_id = '1')
        else '0';

    --------------------------------------------------------------------
    -- REGISTRADOR IF/ID
    --------------------------------------------------------------------

    if_id_instancia : entity work.registrador_if_id
        port map (
            clk               => clk,
            rst               => rst,
            habilita          => habilita_pipeline,
            pc_entrada        => pc_atual,
            instrucao_entrada => instrucao_if,
            valid_entrada     => valid_if_entrada,
            pc_saida          => pc_if_id,
            instrucao_saida   => instrucao_id,
            valid_saida       => valid_if_id
        );

    --------------------------------------------------------------------
    -- ESTAGIO ID: CONTROLE
    --------------------------------------------------------------------

    controle_instancia : entity work.controle
        port map (
            opcode       => instrucao_id(31 downto 26),
            funct        => instrucao_id(5 downto 0),
            reg_dst      => reg_dst_id,
            alu_src      => alu_src_id,
            mem_para_reg => mem_para_reg_id,
            reg_escreve  => reg_escreve_id,
            mem_le       => mem_le_id,
            mem_escreve  => mem_escreve_id,
            branch       => branch_id,
            alu_op       => alu_op_id,
            halt         => halt_id
        );

    --------------------------------------------------------------------
    -- ESTAGIO ID: BANCO DE REGISTRADORES
    --------------------------------------------------------------------

    banco_instancia : entity work.banco_registradores
        port map (
            clk           => clk,
            escreve       => reg_escreve_wb and
                             valid_mem_wb and
                             habilita_pipeline,
            reg_leitura1  => instrucao_id(25 downto 21),
            reg_leitura2  => instrucao_id(20 downto 16),
            reg_escrita   => reg_escrita_wb,
            dado_escrita  => dado_escrita_wb,
            dado_leitura1 => dado1_id,
            dado_leitura2 => dado2_id,
            dbg_reg_addr  => dbg_reg_addr,
            dbg_reg_data  => dbg_reg_data
        );

    imediato_id <= std_logic_vector(
        resize(signed(instrucao_id(15 downto 0)), 32)
    );

    --------------------------------------------------------------------
    -- REGISTRADOR ID/EX
    --------------------------------------------------------------------

    valid_id_ex_entrada <= '1'
        when valid_if_id = '1' and halt_id = '0'
        else '0';

    id_ex_instancia : entity work.registrador_id_ex
        port map (
            clk                  => clk,
            rst                  => rst,
            habilita             => habilita_pipeline,

            pc_entrada           => pc_if_id,
            dado1_entrada        => dado1_id,
            dado2_entrada        => dado2_id,
            imediato_entrada     => imediato_id,

            rs_entrada           => instrucao_id(25 downto 21),
            rt_entrada           => instrucao_id(20 downto 16),
            rd_entrada           => instrucao_id(15 downto 11),

            valid_entrada        => valid_id_ex_entrada,

            reg_dst_entrada      => reg_dst_id,
            alu_src_entrada      => alu_src_id,
            alu_op_entrada       => alu_op_id,
            branch_entrada       => branch_id,
            mem_read_entrada     => mem_le_id,
            mem_write_entrada    => mem_escreve_id,
            reg_write_entrada    => reg_escreve_id,
            mem_para_reg_entrada => mem_para_reg_id,

            pc_saida             => pc_id_ex,
            dado1_saida          => dado1_id_ex,
            dado2_saida          => dado2_id_ex,
            imediato_saida       => imediato_id_ex,

            rs_saida             => rs_id_ex,
            rt_saida             => rt_id_ex,
            rd_saida             => rd_id_ex,

            valid_saida          => valid_id_ex,

            reg_dst_saida        => reg_dst_id_ex,
            alu_src_saida        => alu_src_id_ex,
            alu_op_saida         => alu_op_id_ex,
            branch_saida         => branch_id_ex,
            mem_read_saida       => mem_read_id_ex,
            mem_write_saida      => mem_write_id_ex,
            reg_write_saida      => reg_write_id_ex,
            mem_para_reg_saida   => mem_para_reg_id_ex
        );

    --------------------------------------------------------------------
    -- ESTAGIO EX: ULA E DESVIO
    --------------------------------------------------------------------

    entrada2_ula <= imediato_id_ex
        when alu_src_id_ex = '1'
        else dado2_id_ex;

    ula_instancia : entity work.ula
        port map (
            operacao  => alu_op_id_ex,
            entrada1  => dado1_id_ex,
            entrada2  => entrada2_ula,
            resultado => resultado_ula,
            zero      => zero_ula
        );

    destino_ex <= rd_id_ex
        when reg_dst_id_ex = '1'
        else rt_id_ex;

    branch_taken <= branch_id_ex and zero_ula and valid_id_ex;

    endereco_desvio <= std_logic_vector(
        signed(pc_id_ex) +
        to_signed(4, 32) +
        shift_left(signed(imediato_id_ex), 2)
    );

    --------------------------------------------------------------------
    -- REGISTRADOR EX/MEM
    --------------------------------------------------------------------

    ex_mem_instancia : entity work.registrador_ex_mem
        port map (
            clk                         => clk,
            rst                         => rst,
            habilita                    => habilita_pipeline,

            resultado_ula_entrada       => resultado_ula,
            dado_memoria_entrada        => dado2_id_ex,
            registrador_destino_entrada => destino_ex,

            mem_read_entrada            => mem_read_id_ex,
            mem_write_entrada           => mem_write_id_ex,
            reg_write_entrada           => reg_write_id_ex,
            mem_para_reg_entrada        => mem_para_reg_id_ex,
            valid_entrada               => valid_id_ex,

            resultado_ula_saida         => resultado_ex_mem,
            dado_memoria_saida          => dado_memoria_ex_mem,
            registrador_destino_saida   => destino_ex_mem,

            mem_read_saida              => mem_read_ex_mem,
            mem_write_saida             => mem_write_ex_mem,
            reg_write_saida             => reg_write_ex_mem,
            mem_para_reg_saida          => mem_para_reg_ex_mem,
            valid_saida                 => valid_ex_mem
        );

    --------------------------------------------------------------------
    -- REGISTRADOR MEM/WB
    --------------------------------------------------------------------

    mem_wb_instancia : entity work.registrador_mem_wb
        port map (
            clk                         => clk,
            rst                         => rst,
            habilita                    => habilita_pipeline,

            dado_memoria_entrada        => dado_lido_mem,
            resultado_ula_entrada       => resultado_ex_mem,
            registrador_destino_entrada => destino_ex_mem,

            reg_write_entrada           => reg_write_ex_mem,
            mem_para_reg_entrada        => mem_para_reg_ex_mem,
            valid_entrada               => valid_ex_mem,

            dado_memoria_saida          => dado_mem_wb,
            resultado_ula_saida         => resultado_mem_wb,
            registrador_destino_saida   => destino_mem_wb,

            reg_write_saida             => reg_write_mem_wb,
            mem_para_reg_saida          => mem_para_reg_mem_wb,
            valid_saida                 => valid_mem_wb
        );

    --------------------------------------------------------------------
    -- ESTAGIO WB
    --------------------------------------------------------------------

    dado_escrita_wb <= dado_mem_wb
        when mem_para_reg_mem_wb = '1'
        else resultado_mem_wb;

    reg_escrita_wb <= destino_mem_wb;
    reg_escreve_wb <= reg_write_mem_wb;

    --------------------------------------------------------------------
    -- DETECCAO DOS HAZARDS
    --------------------------------------------------------------------

    process(all)
        variable usa_rs          : boolean;
        variable usa_rt          : boolean;
        variable conflito_dados  : boolean;
        variable destino_id_ex   : std_logic_vector(4 downto 0);
    begin
        detecta_hazard   <= '0';
        tipo_hazard_comb <= "00";
        pc_hazard_comb   <= (others => '0');

        usa_rs         := false;
        usa_rt         := false;
        conflito_dados := false;

        -- Destino da instrução atualmente em ID/EX.
        destino_id_ex := rt_id_ex;
        if reg_dst_id_ex = '1' then
            destino_id_ex := rd_id_ex;
        end if;

        -- Identifica quais registradores-fonte a instrução em ID utiliza.
        if valid_if_id = '1' and halt_id = '0' then
            case instrucao_id(31 downto 26) is

                when "000000" =>
                    -- Instruções tipo R válidas: add, sub, and, or, slt.
                    case instrucao_id(5 downto 0) is
                        when "100000" | "100010" | "100100" |
                             "100101" | "101010" =>
                            usa_rs := true;
                            usa_rt := true;
                        when others =>
                            null;
                    end case;

                when "001000" =>
                    -- addi: lê rs.
                    usa_rs := true;

                when "100011" =>
                    -- lw: lê rs.
                    usa_rs := true;

                when "101011" =>
                    -- sw: lê rs e rt.
                    usa_rs := true;
                    usa_rt := true;

                when "000100" =>
                    -- beq: lê rs e rt.
                    usa_rs := true;
                    usa_rt := true;

                when others =>
                    null;
            end case;

            -- Hazard RAW com produtor em ID/EX.
            if valid_id_ex = '1' and
               reg_write_id_ex = '1' and
               destino_id_ex /= "00000" then

                if (usa_rs and
                    instrucao_id(25 downto 21) = destino_id_ex) or
                   (usa_rt and
                    instrucao_id(20 downto 16) = destino_id_ex) then
                    conflito_dados := true;
                end if;
            end if;

            -- Hazard RAW com produtor em EX/MEM.
            if valid_ex_mem = '1' and
               reg_write_ex_mem = '1' and
               destino_ex_mem /= "00000" then

                if (usa_rs and
                    instrucao_id(25 downto 21) = destino_ex_mem) or
                   (usa_rt and
                    instrucao_id(20 downto 16) = destino_ex_mem) then
                    conflito_dados := true;
                end if;
            end if;
        end if;

        -- Prioridade: dados, estrutural e controle.
        if conflito_dados then
            detecta_hazard   <= '1';
            tipo_hazard_comb <= "01";
            -- R4: hazard_pc aponta para a instrução consumidora.
            pc_hazard_comb   <= pc_if_id;

        elsif MEM_UNIFICADA and
              valid_ex_mem = '1' and
              (mem_read_ex_mem = '1' or mem_write_ex_mem = '1') and
              valid_if_entrada = '1' then

            detecta_hazard   <= '1';
            tipo_hazard_comb <= "10";
            -- R4: IF é a instrução mais nova que não obteve a memória.
            pc_hazard_comb   <= pc_atual;

        elsif branch_taken = '1' and
              (valid_if_id = '1' or valid_if_entrada = '1') then

            detecta_hazard   <= '1';
            tipo_hazard_comb <= "11";
            -- R4: hazard_pc aponta para a instrução de desvio.
            pc_hazard_comb   <= pc_id_ex;
        end if;
    end process;

    --------------------------------------------------------------------
    -- SAIDAS: DONE, RETIRED E STAGE_VALID
    --------------------------------------------------------------------

    done <= '1'
        when stop_fetch = '1' and
             valid_if_id = '0' and
             valid_id_ex = '0' and
             valid_ex_mem = '0' and
             valid_mem_wb = '0' and
             abort_reg = '0' and
             detecta_hazard = '0'
        else '0';

    -- Uma instrução só é contabilizada se WB puder concluir neste ciclo.
    retired <= "01"
        when valid_mem_wb = '1' and
             abort_reg = '0' and
             detecta_hazard = '0' and
             rst = '0'
        else "00";

    -- Bits 4..0: WB, MEM, EX, ID, IF. Bits 9..5 não usados em O2.
    stage_valid(4) <= valid_mem_wb;
    stage_valid(3) <= valid_ex_mem;
    stage_valid(2) <= valid_id_ex;
    stage_valid(1) <= valid_if_id;
    stage_valid(0) <= valid_if_entrada;
    stage_valid(9 downto 5) <= (others => '0');

end architecture comportamento;
