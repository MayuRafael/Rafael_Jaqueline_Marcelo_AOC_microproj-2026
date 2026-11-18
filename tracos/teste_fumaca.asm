# teste_fumaca.asm : programa curto so para verificar se a simulacao roda.
# NAO e o traco T0 do enunciado (T0 tem >= 30 instrucoes uteis e e feito pelo trio).
# Usa todas as instrucoes da ISA, inclusive beq tomado; por isso so serve para a O1.
        addi $t0, $zero, 5      # $t0 = 5
        addi $t1, $zero, 7      # $t1 = 7
        addi $t2, $zero, -3     # $t2 = -3
        add  $t3, $t0, $t1      # $t3 = 12
        sub  $t4, $t1, $t0      # $t4 = 2
        and  $t5, $t0, $t1      # $t5 = 5
        or   $t6, $t0, $t1      # $t6 = 7
        slt  $t7, $t2, $t0      # $t7 = 1  (-3 < 5)
        sw   $t3, 4($zero)      # M[4] = 12
        lw   $s0, 4($zero)      # $s0 = 12
        beq  $t0, $t1, pula1    # nao tomado (5 != 7)
        addi $s1, $zero, 1      # $s1 = 1
pula1:  beq  $t0, $t0, pula2    # tomado
        addi $s2, $zero, 99     # pulada: $s2 continua 0
pula2:  addi $s3, $zero, 2      # $s3 = 2
        break
