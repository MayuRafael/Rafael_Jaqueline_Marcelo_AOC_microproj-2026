# s50.asm : serie S do MicroProj, 50 instrucoes uteis + break.
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
        addi $a0, $t8, 21                        # 0x23040015
        addi $a1, $t9, 22                        # 0x23250016
        add  $a2, $v0, $t9                       # 0x00593020
        sw   $v1, 8($zero)                       # 0xAC030008
        sub  $t0, $a0, $v1                       # 0x00834022
        lw   $t1, 8($zero)                       # 0x8C090008
        and  $t2, $a2, $a1                       # 0x00C55024
        or   $t3, $a3, $a2                       # 0x00E65825
        slt  $t4, $t0, $a3                       # 0x0107602A
        beq  $t1, $t0, 0          # nao tomado   # 0x11280000
        addi $t6, $t2, 31                        # 0x214E001F
        addi $t7, $t3, 32                        # 0x216F0020
        add  $s0, $t4, $t3                       # 0x018B8020
        sw   $t5, 12($zero)                      # 0xAC0D000C
        sub  $s2, $t6, $t5                       # 0x01CD9022
        lw   $s3, 12($zero)                      # 0x8C13000C
        and  $s4, $s0, $t7                       # 0x020FA024
        or   $s5, $s1, $s0                       # 0x0230A825
        slt  $s6, $s2, $s1                       # 0x0251B02A
        beq  $s3, $s2, 0          # nao tomado   # 0x12720000
        addi $t8, $s4, 1                         # 0x22980001
        addi $t9, $s5, 2                         # 0x22B90002
        add  $v0, $s6, $s5                       # 0x02D51020
        sw   $s7, 16($zero)                      # 0xAC170010
        sub  $a0, $t8, $s7                       # 0x03172022
        lw   $a1, 16($zero)                      # 0x8C050010
        and  $a2, $v0, $t9                       # 0x00593024
        or   $a3, $v1, $v0                       # 0x00623825
        slt  $t0, $a0, $v1                       # 0x0083402A
        beq  $a1, $a0, 0          # nao tomado   # 0x10A40000
        break                                    # 0x0000000D
