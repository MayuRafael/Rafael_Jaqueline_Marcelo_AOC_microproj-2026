#!/usr/bin/env python3
"""gera_serie_s.py : gera a serie S do MicroProj (R5).

Cria tracos/sN.asm, tracos/sN.hex e tracos/sN_esperado.txt para
N = 5, 10, 20, 50, 100 e 200 instrucoes uteis (mais o break final).

Os tracos seguem as mesmas regras do T0, para que nao haja conflito na O2:
  - quem le um registrador fica a 4 instrucoes de quem o escreveu (minimo seguro: 3,
    porque o banco escreve na 1a metade do ciclo e le na 2a);
  - todo beq e NAO tomado (compara dois registradores com valores diferentes);
  - so registradores $t, $s, $v e $a; memoria de dados nos enderecos 0 a 252.
A mistura de instrucoes repete o padrao do T0 (aritmetica, memoria, logica,
comparacao e desvio). O script monta o .hex e calcula o esperado com um
montador e um simulador MIPS proprios, e confere que nao ha conflito.

Uso:  python3 scripts/gera_serie_s.py      (na raiz do repositorio)

Uso de IA: script escrito com apoio do Claude (Anthropic); declarar no Apendice C.
"""
import os
import sys

TAMANHOS = [5, 10, 20, 50, 100, 200]
DISTANCIA = 4  # distancia entre quem escreve e quem le (seguro: >= 3)

NOME = {2: 'v0', 3: 'v1', 4: 'a0', 5: 'a1', 6: 'a2', 7: 'a3',
        8: 't0', 9: 't1', 10: 't2', 11: 't3', 12: 't4', 13: 't5', 14: 't6', 15: 't7',
        16: 's0', 17: 's1', 18: 's2', 19: 's3', 20: 's4', 21: 's5', 22: 's6', 23: 's7',
        24: 't8', 25: 't9'}
# Registradores usados como destino, em rodizio
POOL = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 2, 3, 4, 5, 6, 7]
# Padrao de instrucoes repetido (mesma mistura de classes do T0)
PADRAO = ['addi', 'addi', 'add', 'sw', 'sub', 'lw', 'and', 'or', 'slt', 'beq']

FUNCT = {'add': 0x20, 'sub': 0x22, 'and': 0x24, 'or': 0x25, 'slt': 0x2A}
MASK = 0xFFFFFFFF


def com_sinal(v):
    return v - (1 << 32) if v & 0x80000000 else v


def codifica(op, rd=0, rs=0, rt=0, imm=0):
    """Monta uma instrucao MIPS em 32 bits."""
    if op in FUNCT:
        return (rs << 21) | (rt << 16) | (rd << 11) | FUNCT[op]
    if op == 'break':
        return 0x0000000D
    opcode = {'addi': 0x08, 'lw': 0x23, 'sw': 0x2B, 'beq': 0x04}[op]
    return (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)


def gera(n):
    """Gera n instrucoes uteis sem conflito; devolve (linhas_asm, palavras, regs)."""
    reg = [0] * 32
    mem = {}
    ultima_escrita = {}
    asm, palavras = [], []
    end_sw = 0          # proximo endereco de escrita na memoria
    lidos = []          # enderecos ja escritos (para os lw)

    def fonte(i, k):
        """Registrador escrito a DISTANCIA+k instrucoes antes (ou ainda nao escrito)."""
        return POOL[(i - DISTANCIA - k) % len(POOL)]

    for i in range(n):
        op = PADRAO[i % len(PADRAO)]
        dest = POOL[i % len(POOL)]
        rs, rt = fonte(i, 0), fonte(i, 1)

        if op == 'addi':
            imm = (i % 40) + 1
            palavras.append(codifica('addi', rt=dest, rs=rs, imm=imm))
            asm.append(f"addi ${NOME[dest]}, ${NOME[rs]}, {imm}")
            reg[dest] = (reg[rs] + imm) & MASK
            ultima_escrita[dest] = i
        elif op in FUNCT:
            palavras.append(codifica(op, rd=dest, rs=rs, rt=rt))
            asm.append(f"{op:<4} ${NOME[dest]}, ${NOME[rs]}, ${NOME[rt]}")
            a, b = reg[rs], reg[rt]
            reg[dest] = {'add': a + b, 'sub': a - b, 'and': a & b, 'or': a | b,
                         'slt': int(com_sinal(a) < com_sinal(b))}[op] & MASK
            ultima_escrita[dest] = i
        elif op == 'sw':
            palavras.append(codifica('sw', rt=rs, rs=0, imm=end_sw))
            asm.append(f"sw   ${NOME[rs]}, {end_sw}($zero)")
            mem[end_sw] = reg[rs]
            lidos.append(end_sw)
            end_sw = (end_sw + 4) % 256
        elif op == 'lw':
            end = lidos[-1] if lidos else 0
            palavras.append(codifica('lw', rt=dest, rs=0, imm=end))
            asm.append(f"lw   ${NOME[dest]}, {end}($zero)")
            reg[dest] = mem.get(end, 0)
            ultima_escrita[dest] = i
        elif op == 'beq':
            # escolhe dois registradores "maduros" com valores diferentes: nao tomado
            par = None
            for k in range(0, len(POOL) - DISTANCIA):
                a, b = fonte(i, k), fonte(i, k + 1)
                if reg[a] != reg[b]:
                    par = (a, b)
                    break
            if par is None:  # todos iguais: compara com $zero um registrador nao nulo
                par = next(((r, 0) for r in POOL if reg[r] != 0 and i - ultima_escrita.get(r, -99) >= DISTANCIA), None)
            if par is None:  # sem par seguro: troca por addi
                imm = (i % 40) + 1
                palavras.append(codifica('addi', rt=dest, rs=rs, imm=imm))
                asm.append(f"addi ${NOME[dest]}, ${NOME[rs]}, {imm}")
                reg[dest] = (reg[rs] + imm) & MASK
                ultima_escrita[dest] = i
                continue
            a, b = par
            palavras.append(codifica('beq', rs=a, rt=b, imm=0))
            nome_b = NOME.get(b, 'zero')
            asm.append(f"beq  ${NOME[a]}, ${nome_b}, 0          # nao tomado")

    palavras.append(codifica('break'))
    asm.append("break")
    return asm, palavras, reg


def confere(palavras):
    """Simula o programa e verifica: sem conflito de dados e sem beq tomado."""
    reg = [0] * 32
    mem = {}
    ultima = {}
    pc, i = 0, 0
    while True:
        w = palavras[pc // 4]
        op, rs, rt, rd = w >> 26, (w >> 21) & 31, (w >> 16) & 31, (w >> 11) & 31
        imm = w & 0xFFFF
        imm = imm - 0x10000 if imm & 0x8000 else imm
        if op == 0 and (w & 63) == 0x0D:
            return reg, i
        lidos = [rs, rt] if op in (0, 0x2B, 0x04) else [rs]
        for r in lidos:
            if r and r in ultima and i - ultima[r] < 3:
                sys.exit(f"ERRO: conflito de dados no PC 0x{pc:X} (reg {r})")
        if op == 0x04 and reg[rs] == reg[rt]:
            sys.exit(f"ERRO: beq tomado no PC 0x{pc:X}")
        escrito = None
        if op == 0:
            a, b = reg[rs], reg[rt]
            v = {0x20: a + b, 0x22: a - b, 0x24: a & b, 0x25: a | b,
                 0x2A: int(com_sinal(a) < com_sinal(b))}[w & 63]
            escrito = (rd, v)
        elif op == 0x08:
            escrito = (rt, reg[rs] + imm)
        elif op == 0x23:
            escrito = (rt, mem.get((reg[rs] + imm) & MASK, 0))
        elif op == 0x2B:
            mem[(reg[rs] + imm) & MASK] = reg[rt]
        if escrito and escrito[0]:
            reg[escrito[0]] = escrito[1] & MASK
            ultima[escrito[0]] = i
        pc += 4
        i += 1


def main():
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pasta = os.path.join(raiz, 'tracos')
    for n in TAMANHOS:
        asm, palavras, reg = gera(n)
        reg_sim, uteis = confere(palavras)
        assert uteis == n and reg_sim == reg, f"inconsistencia em s{n}"
        base = os.path.join(pasta, f"s{n}")
        with open(base + '.asm', 'w', newline='\n') as f:
            f.write(f"# s{n}.asm : serie S do MicroProj, {n} instrucoes uteis + break.\n")
            f.write("# Gerado por scripts/gera_serie_s.py (mesmas regras do T0: sem conflitos em O1 e O2).\n")
            for a, w in zip(asm, palavras):
                f.write(f"        {a:<40} # 0x{w:08X}\n")
        with open(base + '.hex', 'w', newline='\n') as f:
            f.write('\n'.join(f"{w:08x}" for w in palavras) + '\n')
        with open(base + '_esperado.txt', 'w', newline='\n') as f:
            f.write(f"# s{n}_esperado.txt : valores finais dos registradores\n")
            f.write("# formato: <registrador em decimal> <valor em hexadecimal>\n")
            for r in sorted(NOME):
                f.write(f"{r} {reg[r]:08X}\n")
        print(f"s{n}: {n} instrucoes uteis, sem conflitos -> tracos/s{n}.asm/.hex/_esperado.txt")


if __name__ == '__main__':
    main()
