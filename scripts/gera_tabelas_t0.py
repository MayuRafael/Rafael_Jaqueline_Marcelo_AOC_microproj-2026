#!/usr/bin/env python3
"""Gera as tabelas do traço T0 exigidas pelo enunciado (seção 6).

Uso, na raiz do repositório:
    python3 scripts/gera_tabelas_t0.py

Saídas em graficos/:
    tabela_t0.csv          endereço, instrução, registradores lidos e escrito,
                           distância até o produtor mais próximo
    instr_ciclo_o1.csv     diagrama instrução x ciclo da O1 (10 primeiras e 3 últimas)
    instr_ciclo_o2.csv     diagrama instrução x ciclo da O2 (10 primeiras e 3 últimas)

A O1 executa a instrução k inteira no ciclo k. Na O2, a instrução k entra no IF
no ciclo k e passa por ID, EX, MEM e WB nos quatro ciclos seguintes (o T0 não
tem conflitos, então não há bolhas). As "3 últimas" são as três últimas
instruções úteis (o break não conta).
"""
import csv
import os
import re
import sys

ESTAGIOS = ['IF', 'ID', 'EX', 'MEM', 'WB']


def le_programa(caminho):
    prog = []
    for linha in open(caminho):
        codigo = linha.split('#')[0]
        codigo = re.sub(r'^\s*\w+:\s*', '', codigo).strip()
        if not codigo:
            continue
        mnem, _, resto = codigo.partition(' ')
        ops = [o.strip() for o in resto.split(',')] if resto.strip() else []
        prog.append((mnem, ops, codigo))
    return prog


def regs(mnem, ops):
    """Devolve (lidos, escrito) de uma instrução do subconjunto."""
    if mnem in ('add', 'sub', 'and', 'or', 'slt'):
        return [ops[1], ops[2]], ops[0]
    if mnem == 'addi':
        return [ops[1]], ops[0]
    if mnem == 'lw':
        return [re.search(r'\((\$\w+)\)', ops[1]).group(1)], ops[0]
    if mnem == 'sw':
        return [ops[0], re.search(r'\((\$\w+)\)', ops[1]).group(1)], None
    if mnem == 'beq':
        return [ops[0], ops[1]], None
    return [], None


def main():
    asm = sys.argv[1] if len(sys.argv) > 1 else 'tracos/t0.asm'
    saida = sys.argv[2] if len(sys.argv) > 2 else 'graficos'
    os.makedirs(saida, exist_ok=True)
    prog = le_programa(asm)

    # Tabela do traço
    ultima_escrita = {}
    linhas = []
    for i, (mnem, ops, texto) in enumerate(prog):
        lidos, escrito = regs(mnem, ops)
        lidos_validos = [r for r in lidos if r != '$zero']
        dists = [i - ultima_escrita[r] for r in lidos_validos if r in ultima_escrita]
        dist = str(min(dists)) if dists else '—'
        linhas.append([f'0x{4 * i:02X}', re.sub(r'\s+', ' ', texto),
                       ', '.join(dict.fromkeys(lidos)) or '—', escrito or '—', dist])
        if escrito and escrito != '$zero':
            ultima_escrita[escrito] = i
    with open(os.path.join(saida, 'tabela_t0.csv'), 'w', newline='') as f:
        w = csv.writer(f, delimiter=';')
        w.writerow(['endereco', 'instrucao', 'lidos', 'escrito', 'distancia'])
        w.writerows(linhas)

    uteis = [i for i, (m, _, _) in enumerate(prog) if m != 'break']
    escolhidas = uteis[:10] + uteis[-3:]

    def diagrama(nome, estagios_de):
        ciclos = sorted({c for i in escolhidas for c in estagios_de(i)})
        with open(os.path.join(saida, nome), 'w', newline='') as f:
            w = csv.writer(f, delimiter=';')
            w.writerow(['instrucao'] + [f'C{c}' for c in ciclos])
            for i in escolhidas:
                mapa = estagios_de(i)
                w.writerow([f'{linhas[i][1]} ({linhas[i][0]})'] + [mapa.get(c, '') for c in ciclos])

    diagrama('instr_ciclo_o1.csv', lambda i: {i + 1: 'IF-WB'})
    diagrama('instr_ciclo_o2.csv', lambda i: {i + 1 + k: e for k, e in enumerate(ESTAGIOS)})
    print(f'Tabelas do T0 gravadas em {saida}/')


if __name__ == '__main__':
    main()
