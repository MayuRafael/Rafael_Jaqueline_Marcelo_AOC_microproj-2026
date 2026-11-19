# s200.asm : serie S do MicroProj, 200 instrucoes uteis + break.
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
        addi $t2, $a2, 11                        # 0x20CA000B
        addi $t3, $a3, 12                        # 0x20EB000C
        add  $t4, $t0, $a3                       # 0x01076020
        sw   $t1, 20($zero)                      # 0xAC090014
        sub  $t6, $t2, $t1                       # 0x01497022
        lw   $t7, 20($zero)                      # 0x8C0F0014
        and  $s0, $t4, $t3                       # 0x018B8024
        or   $s1, $t5, $t4                       # 0x01AC8825
        slt  $s2, $t6, $t5                       # 0x01CD902A
        beq  $t7, $t6, 0          # nao tomado   # 0x11EE0000
        addi $s4, $s0, 21                        # 0x22140015
        addi $s5, $s1, 22                        # 0x22350016
        add  $s6, $s2, $s1                       # 0x0251B020
        sw   $s3, 24($zero)                      # 0xAC130018
        sub  $t8, $s4, $s3                       # 0x0293C022
        lw   $t9, 24($zero)                      # 0x8C190018
        and  $v0, $s6, $s5                       # 0x02D51024
        or   $v1, $s7, $s6                       # 0x02F61825
        slt  $a0, $t8, $s7                       # 0x0317202A
        beq  $t9, $t8, 0          # nao tomado   # 0x13380000
        addi $a2, $v0, 31                        # 0x2046001F
        addi $a3, $v1, 32                        # 0x20670020
        add  $t0, $a0, $v1                       # 0x00834020
        sw   $a1, 28($zero)                      # 0xAC05001C
        sub  $t2, $a2, $a1                       # 0x00C55022
        lw   $t3, 28($zero)                      # 0x8C0B001C
        and  $t4, $t0, $a3                       # 0x01076024
        or   $t5, $t1, $t0                       # 0x01286825
        slt  $t6, $t2, $t1                       # 0x0149702A
        beq  $t3, $t2, 0          # nao tomado   # 0x116A0000
        addi $s0, $t4, 1                         # 0x21900001
        addi $s1, $t5, 2                         # 0x21B10002
        add  $s2, $t6, $t5                       # 0x01CD9020
        sw   $t7, 32($zero)                      # 0xAC0F0020
        sub  $s4, $s0, $t7                       # 0x020FA022
        lw   $s5, 32($zero)                      # 0x8C150020
        and  $s6, $s2, $s1                       # 0x0251B024
        or   $s7, $s3, $s2                       # 0x0272B825
        slt  $t8, $s4, $s3                       # 0x0293C02A
        beq  $s5, $s4, 0          # nao tomado   # 0x12B40000
        addi $v0, $s6, 11                        # 0x22C2000B
        addi $v1, $s7, 12                        # 0x22E3000C
        add  $a0, $t8, $s7                       # 0x03172020
        sw   $t9, 36($zero)                      # 0xAC190024
        sub  $a2, $v0, $t9                       # 0x00593022
        lw   $a3, 36($zero)                      # 0x8C070024
        and  $t0, $a0, $v1                       # 0x00834024
        or   $t1, $a1, $a0                       # 0x00A44825
        slt  $t2, $a2, $a1                       # 0x00C5502A
        beq  $a3, $a2, 0          # nao tomado   # 0x10E60000
        addi $t4, $t0, 21                        # 0x210C0015
        addi $t5, $t1, 22                        # 0x212D0016
        add  $t6, $t2, $t1                       # 0x01497020
        sw   $t3, 40($zero)                      # 0xAC0B0028
        sub  $s0, $t4, $t3                       # 0x018B8022
        lw   $s1, 40($zero)                      # 0x8C110028
        and  $s2, $t6, $t5                       # 0x01CD9024
        or   $s3, $t7, $t6                       # 0x01EE9825
        slt  $s4, $s0, $t7                       # 0x020FA02A
        beq  $s1, $s0, 0          # nao tomado   # 0x12300000
        addi $s6, $s2, 31                        # 0x2256001F
        addi $s7, $s3, 32                        # 0x22770020
        add  $t8, $s4, $s3                       # 0x0293C020
        sw   $s5, 44($zero)                      # 0xAC15002C
        sub  $v0, $s6, $s5                       # 0x02D51022
        lw   $v1, 44($zero)                      # 0x8C03002C
        and  $a0, $t8, $s7                       # 0x03172024
        or   $a1, $t9, $t8                       # 0x03382825
        slt  $a2, $v0, $t9                       # 0x0059302A
        beq  $v1, $v0, 0          # nao tomado   # 0x10620000
        addi $t0, $a0, 1                         # 0x20880001
        addi $t1, $a1, 2                         # 0x20A90002
        add  $t2, $a2, $a1                       # 0x00C55020
        sw   $a3, 48($zero)                      # 0xAC070030
        sub  $t4, $t0, $a3                       # 0x01076022
        lw   $t5, 48($zero)                      # 0x8C0D0030
        and  $t6, $t2, $t1                       # 0x01497024
        or   $t7, $t3, $t2                       # 0x016A7825
        slt  $s0, $t4, $t3                       # 0x018B802A
        beq  $t5, $t4, 0          # nao tomado   # 0x11AC0000
        addi $s2, $t6, 11                        # 0x21D2000B
        addi $s3, $t7, 12                        # 0x21F3000C
        add  $s4, $s0, $t7                       # 0x020FA020
        sw   $s1, 52($zero)                      # 0xAC110034
        sub  $s6, $s2, $s1                       # 0x0251B022
        lw   $s7, 52($zero)                      # 0x8C170034
        and  $t8, $s4, $s3                       # 0x0293C024
        or   $t9, $s5, $s4                       # 0x02B4C825
        slt  $v0, $s6, $s5                       # 0x02D5102A
        beq  $s7, $s6, 0          # nao tomado   # 0x12F60000
        addi $a0, $t8, 21                        # 0x23040015
        addi $a1, $t9, 22                        # 0x23250016
        add  $a2, $v0, $t9                       # 0x00593020
        sw   $v1, 56($zero)                      # 0xAC030038
        sub  $t0, $a0, $v1                       # 0x00834022
        lw   $t1, 56($zero)                      # 0x8C090038
        and  $t2, $a2, $a1                       # 0x00C55024
        or   $t3, $a3, $a2                       # 0x00E65825
        slt  $t4, $t0, $a3                       # 0x0107602A
        beq  $t1, $t0, 0          # nao tomado   # 0x11280000
        addi $t6, $t2, 31                        # 0x214E001F
        addi $t7, $t3, 32                        # 0x216F0020
        add  $s0, $t4, $t3                       # 0x018B8020
        sw   $t5, 60($zero)                      # 0xAC0D003C
        sub  $s2, $t6, $t5                       # 0x01CD9022
        lw   $s3, 60($zero)                      # 0x8C13003C
        and  $s4, $s0, $t7                       # 0x020FA024
        or   $s5, $s1, $s0                       # 0x0230A825
        slt  $s6, $s2, $s1                       # 0x0251B02A
        beq  $s3, $s2, 0          # nao tomado   # 0x12720000
        addi $t8, $s4, 1                         # 0x22980001
        addi $t9, $s5, 2                         # 0x22B90002
        add  $v0, $s6, $s5                       # 0x02D51020
        sw   $s7, 64($zero)                      # 0xAC170040
        sub  $a0, $t8, $s7                       # 0x03172022
        lw   $a1, 64($zero)                      # 0x8C050040
        and  $a2, $v0, $t9                       # 0x00593024
        or   $a3, $v1, $v0                       # 0x00623825
        slt  $t0, $a0, $v1                       # 0x0083402A
        beq  $a1, $a0, 0          # nao tomado   # 0x10A40000
        addi $t2, $a2, 11                        # 0x20CA000B
        addi $t3, $a3, 12                        # 0x20EB000C
        add  $t4, $t0, $a3                       # 0x01076020
        sw   $t1, 68($zero)                      # 0xAC090044
        sub  $t6, $t2, $t1                       # 0x01497022
        lw   $t7, 68($zero)                      # 0x8C0F0044
        and  $s0, $t4, $t3                       # 0x018B8024
        or   $s1, $t5, $t4                       # 0x01AC8825
        slt  $s2, $t6, $t5                       # 0x01CD902A
        beq  $t7, $t6, 0          # nao tomado   # 0x11EE0000
        addi $s4, $s0, 21                        # 0x22140015
        addi $s5, $s1, 22                        # 0x22350016
        add  $s6, $s2, $s1                       # 0x0251B020
        sw   $s3, 72($zero)                      # 0xAC130048
        sub  $t8, $s4, $s3                       # 0x0293C022
        lw   $t9, 72($zero)                      # 0x8C190048
        and  $v0, $s6, $s5                       # 0x02D51024
        or   $v1, $s7, $s6                       # 0x02F61825
        slt  $a0, $t8, $s7                       # 0x0317202A
        beq  $t9, $t8, 0          # nao tomado   # 0x13380000
        addi $a2, $v0, 31                        # 0x2046001F
        addi $a3, $v1, 32                        # 0x20670020
        add  $t0, $a0, $v1                       # 0x00834020
        sw   $a1, 76($zero)                      # 0xAC05004C
        sub  $t2, $a2, $a1                       # 0x00C55022
        lw   $t3, 76($zero)                      # 0x8C0B004C
        and  $t4, $t0, $a3                       # 0x01076024
        or   $t5, $t1, $t0                       # 0x01286825
        slt  $t6, $t2, $t1                       # 0x0149702A
        beq  $t3, $t2, 0          # nao tomado   # 0x116A0000
        break                                    # 0x0000000D
