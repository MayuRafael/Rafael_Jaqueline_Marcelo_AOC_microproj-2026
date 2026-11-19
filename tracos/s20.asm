# s20.asm : serie S do MicroProj, 20 instrucoes uteis + break.
# Gerado por scripts/gera_serie_s.py (mesmas regras do T0: sem conflitos em O1 e O2).
        addi $t0, $a0, 1                         # 0x20880001
        addi $t1, $a1, 2                         # 0x20A90002
        add  $t2, $a2, $a1                       # 0x00C55020
        sw   $a3, 0($zero)                       # 0xAC070000
        sub  $t4, $t0, $a3                       # 0x01076022
        lw   $t5, 0($zero)                       # 0x8C0D0000
        and  $t6, $t2, $t1                       # 0x01497024
        or   $t7, $t3, $t2                       # 0x016A7825
        slt  $s0, $t4, $t3                       # 0x018B802A
        beq  $t5, $t4, 0          # nao tomado   # 0x11AC0000
        addi $s2, $t6, 11                        # 0x21D2000B
        addi $s3, $t7, 12                        # 0x21F3000C
        add  $s4, $s0, $t7                       # 0x020FA020
        sw   $s1, 4($zero)                       # 0xAC110004
        sub  $s6, $s2, $s1                       # 0x0251B022
        lw   $s7, 4($zero)                       # 0x8C170004
        and  $t8, $s4, $s3                       # 0x0293C024
        or   $t9, $s5, $s4                       # 0x02B4C825
        slt  $v0, $s6, $s5                       # 0x02D5102A
        beq  $s7, $s6, 0          # nao tomado   # 0x12F60000
        break                                    # 0x0000000D
