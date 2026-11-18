# t0.asm : traco limpo T0 do MicroProj (R5)
# 30 instrucoes uteis + break, todas as classes da ISA, sem conflitos em O1 e O2.
# Regras usadas para nao haver conflito na O2 (sem forwarding, stall nem flush):
#  - quem le um registrador fica a 3 ou mais instrucoes de quem o escreveu
#    (o banco escreve na 1a metade do ciclo e le na 2a);
#  - o beq e NAO tomado (desvio tomado com instrucoes ja buscadas = conflito de controle);
#  - so registradores $v, $a, $t e $s (sem $gp, $sp, $fp, $k0, $k1).
# Baseado no programa de teste do trio, reorganizado: os addi de $a0 e $a1 foram
# movidos para o inicio e entrou um addi a mais para chegar a 30 instrucoes uteis.
# Memoria de dados: enderecos 0 a 16 (o processador comeca o PC em 0 e usa
# memorias de instrucoes e dados separadas).

        # --- inicializacao (aritmetica com imediato) ---
        addi $t0, $zero, 1      # 0x00  $t0 = 1
        addi $t1, $zero, 2      # 0x04  $t1 = 2
        addi $t2, $zero, 3      # 0x08  $t2 = 3
        addi $t3, $zero, 4      # 0x0C  $t3 = 4
        addi $t4, $zero, 5      # 0x10  $t4 = 5
        addi $a0, $zero, 10     # 0x14  $a0 = 10
        addi $a1, $zero, 20     # 0x18  $a1 = 20

        # --- aritmetica e logica (tipo R) ---
        add  $t5, $t0, $t1      # 0x1C  $t5 = 3
        sub  $t6, $t2, $t0      # 0x20  $t6 = 2
        and  $t7, $t3, $t4      # 0x24  $t7 = 4
        or   $s0, $t3, $t4      # 0x28  $s0 = 5
        slt  $s1, $t0, $t1      # 0x2C  $s1 = 1

        # --- escrita na memoria ---
        sw   $t5, 0($zero)      # 0x30  M[0]  = 3
        sw   $t6, 4($zero)      # 0x34  M[4]  = 2
        sw   $t7, 8($zero)      # 0x38  M[8]  = 4
        sw   $s0, 12($zero)     # 0x3C  M[12] = 5
        sw   $s1, 16($zero)     # 0x40  M[16] = 1

        # --- leitura da memoria ---
        lw   $s2, 0($zero)      # 0x44  $s2 = 3
        lw   $s3, 4($zero)      # 0x48  $s3 = 2
        lw   $s4, 8($zero)      # 0x4C  $s4 = 4
        lw   $s5, 12($zero)     # 0x50  $s5 = 5
        lw   $s6, 16($zero)     # 0x54  $s6 = 1

        # --- operacoes com os valores lidos ---
        add  $s7, $s2, $s3      # 0x58  $s7 = 5
        sub  $t8, $s4, $s3      # 0x5C  $t8 = 2
        and  $t9, $s5, $s6      # 0x60  $t9 = 1
        or   $v0, $s5, $s6      # 0x64  $v0 = 5
        slt  $v1, $s3, $s2      # 0x68  $v1 = 1
        add  $a2, $a0, $a1      # 0x6C  $a2 = 30
        addi $a3, $zero, 7      # 0x70  $a3 = 7

        # --- desvio nao tomado ---
        beq  $a0, $a1, fim      # 0x74  10 != 20: nao tomado
fim:    break                   # 0x78  fim do programa (nao conta como util)
