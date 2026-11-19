# s5.asm : serie S do MicroProj, 5 instrucoes uteis + break.
# Gerado por scripts/gera_serie_s.py (mesmas regras do T0: sem conflitos em O1 e O2).
        addi $t0, $a0, 1                         # 0x20880001
        addi $t1, $a1, 2                         # 0x20A90002
        add  $t2, $a2, $a1                       # 0x00C55020
        sw   $a3, 0($zero)                       # 0xAC070000
        sub  $t4, $t0, $a3                       # 0x01076022
        break                                    # 0x0000000D
