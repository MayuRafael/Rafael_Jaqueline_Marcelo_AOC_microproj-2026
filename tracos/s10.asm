# s10.asm : serie S do MicroProj, 10 instrucoes uteis + break.
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
        break                                    # 0x0000000D
