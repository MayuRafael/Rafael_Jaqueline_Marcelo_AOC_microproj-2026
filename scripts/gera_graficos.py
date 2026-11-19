#!/usr/bin/env python3
"""Gera a Tabela 4 e os gráficos do relatório a partir do metricas.csv.

Uso, na raiz do repositório (depois de bash run_all.sh):
    python3 scripts/gera_graficos.py

Saídas em graficos/:
    tabela4.csv              métricas por organização e traço, com tempo e speedup
    fig6_cpi.png             CPI por organização no T0
    fig7_speedup.png         speedup medido de O2 sobre O1 e speedup ideal
    fig8_speedup_serie.png   speedup em função do tamanho do traço (série S)

Os períodos de clock vêm da Seção 3.4 do relatório (tabela de atrasos de
Patterson e Hennessy mais 50 ps de overhead por registrador, de Harris e Harris).
Para usar outros valores: python3 scripts/gera_graficos.py --t-o1 850 --t-o2 250
"""
import argparse
import csv
import os
import re
import sys

T_O1_PS = 850  # monociclo: lw (800 ps) + overhead do PC (50 ps)
T_O2_PS = 250  # pipeline: estágio mais lento (200 ps) + overhead do registrador (50 ps)

COR_O1 = '#2a78d6'
COR_O2 = '#eb6834'
COR_IDEAL = '#6b6a64'


def nome_traco(programa):
    """tracos/s50.hex -> S50; tracos/t0.hex -> T0."""
    return os.path.splitext(os.path.basename(programa))[0].upper()


def tamanho(traco):
    m = re.fullmatch(r'S(\d+)', traco)
    return int(m.group(1)) if m else None


def le_metricas(caminho):
    linhas = {}
    with open(caminho, newline='') as f:
        for r in csv.DictReader(f, delimiter=';'):
            if int(r['instrucoes']) == 0:  # traços de conflito (abortam): fora da Tabela 4
                continue
            linhas[(r['org'], nome_traco(r['programa']))] = {
                'ciclos': int(r['ciclos']),
                'instrucoes': int(r['instrucoes']),
                'cpi': float(r['CPI']),
                'ipc': float(r['IPC']),
                'ocupacao': float(r['ocupacao']),
                'erros': int(r['erros']),
            }
    return linhas


def ordem_tracos(linhas):
    tracos = sorted({t for (_, t) in linhas})
    return sorted(tracos, key=lambda t: (t != 'T0', tamanho(t) or 0))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--csv', default='metricas.csv')
    ap.add_argument('--saida', default='graficos')
    ap.add_argument('--t-o1', type=float, default=T_O1_PS, help='período da O1 em ps')
    ap.add_argument('--t-o2', type=float, default=T_O2_PS, help='período da O2 em ps')
    a = ap.parse_args()

    if not os.path.exists(a.csv):
        sys.exit(f'ERRO: {a.csv} não encontrado. Rode antes: bash run_all.sh')
    linhas = le_metricas(a.csv)
    tracos = ordem_tracos(linhas)
    periodo = {'O1': a.t_o1, 'O2': a.t_o2}
    ideal = a.t_o1 / a.t_o2  # CPI = 1 nas duas organizações (pipeline sempre cheio)
    os.makedirs(a.saida, exist_ok=True)

    # Tabela 4
    speedup = {}
    tab = []
    for t in tracos:
        for org in ('O1', 'O2'):
            m = linhas.get((org, t))
            if m is None:
                continue
            tempo_ns = m['ciclos'] * periodo[org] / 1000.0
            m['tempo_ns'] = tempo_ns
            tab.append((org, t, m))
        if ('O1', t) in linhas and ('O2', t) in linhas:
            speedup[t] = linhas[('O1', t)]['tempo_ns'] / linhas[('O2', t)]['tempo_ns']

    caminho_tab = os.path.join(a.saida, 'tabela4.csv')
    with open(caminho_tab, 'w', newline='') as f:
        w = csv.writer(f, delimiter=';')
        w.writerow(['org', 'traco', 'ciclos', 'instrucoes', 'CPI', 'IPC', 'ocupacao',
                    'periodo_ps', 'tempo_ns', 'speedup_medido', 'speedup_ideal'])
        for org, t, m in tab:
            sp = f'{speedup[t]:.2f}' if org == 'O2' and t in speedup else ''
            si = f'{ideal:.2f}' if org == 'O2' else ''
            w.writerow([org, t, m['ciclos'], m['instrucoes'], f"{m['cpi']:.3f}",
                        f"{m['ipc']:.3f}", f"{m['ocupacao']:.3f}", f'{periodo[org]:g}',
                        f"{m['tempo_ns']:.2f}", sp, si])

    print(f'Períodos: O1 = {a.t_o1:g} ps, O2 = {a.t_o2:g} ps; speedup ideal = {ideal:.2f}')
    print(f"{'Org':<4}{'Traço':<7}{'Ciclos':>7}{'Instr.':>7}{'CPI':>7}{'IPC':>7}"
          f"{'Ocup.':>7}{'Tempo(ns)':>11}{'Speedup':>9}")
    for org, t, m in tab:
        sp = f'{speedup[t]:.2f}' if org == 'O2' and t in speedup else ''
        print(f"{org:<4}{t:<7}{m['ciclos']:>7}{m['instrucoes']:>7}{m['cpi']:>7.3f}"
              f"{m['ipc']:>7.3f}{m['ocupacao']:>7.3f}{m['tempo_ns']:>11.2f}{sp:>9}")
    print(f'Tabela gravada em {caminho_tab}')

    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        from matplotlib.ticker import FuncFormatter
    except ImportError:
        print('AVISO: matplotlib não instalado; gráficos não gerados.\n'
              '       Instale com: sudo apt install python3-matplotlib')
        return

    plt.rcParams.update({
        'font.size': 8, 'axes.spines.top': False, 'axes.spines.right': False,
        'axes.edgecolor': '#888780', 'axes.grid': True, 'axes.axisbelow': True,
        'grid.color': '#e4e2da', 'grid.linewidth': 0.6, 'legend.frameon': False,
    })
    x = list(range(len(tracos)))
    larg = 0.38
    virgula = FuncFormatter(lambda v, _: f'{v:g}'.replace('.', ','))

    def br(v):
        return f'{v:.2f}'.replace('.', ',')

    # Figura 6: CPI por organização no T0 (uma barra por organização, como no enunciado)
    fig, ax = plt.subplots(figsize=(3.2, 2.4))
    orgs = [('O1', 'O1 (monociclo)', COR_O1), ('O2', 'O2 (pipeline)', COR_O2)]
    ys = [linhas[(o, 'T0')]['cpi'] for o, _, _ in orgs]
    ax.bar([0, 1], ys, 0.55, color=[c for _, _, c in orgs])
    for xi, y in zip([0, 1], ys):
        ax.text(xi, y - 0.05, br(y), ha='center', va='top', fontsize=8, color='white')
    ax.set_xticks([0, 1], [n for _, n, _ in orgs])
    ax.set_ylabel('CPI no T0')
    ax.yaxis.set_major_formatter(virgula)
    ax.grid(axis='x', visible=False)
    fig.tight_layout()
    fig.savefig(os.path.join(a.saida, 'fig6_cpi.png'), dpi=250)
    plt.close(fig)

    # Figura 7: speedup medido e ideal
    fig, ax = plt.subplots(figsize=(3.2, 2.4))
    ys = [speedup[t] for t in tracos]
    ax.bar(x, ys, 0.6, color=COR_O2, label='Speedup medido')
    for xi, y in zip(x, ys):
        ax.text(xi, y - 0.1, br(y), ha='center', va='top', fontsize=6, color='white', rotation=90)
    ax.axhline(ideal, color=COR_IDEAL, linestyle='--', linewidth=1.2,
               label=f'Speedup ideal ({br(ideal)})')
    ax.set_xticks(x, tracos)
    ax.tick_params(axis='x', labelsize=7)
    ax.set_ylabel('Speedup O2/O1')
    ax.set_xlabel('Traço')
    ax.set_ylim(0, ideal * 1.35)
    ax.yaxis.set_major_formatter(virgula)
    ax.grid(axis='x', visible=False)
    ax.legend(loc='upper left', ncol=2, fontsize=6.5, handlelength=1.5, columnspacing=1)
    fig.tight_layout()
    fig.savefig(os.path.join(a.saida, 'fig7_speedup.png'), dpi=250)
    plt.close(fig)

    # Figura 8: speedup em função do tamanho do traço (série S)
    serie = sorted((tamanho(t), speedup[t]) for t in tracos if tamanho(t))
    if serie:
        fig, ax = plt.subplots(figsize=(3.2, 2.4))
        ns, sps = zip(*serie)
        ax.plot(ns, sps, color=COR_O2, linewidth=2, marker='o', markersize=5,
                label='Speedup medido (série S)')
        ax.axhline(ideal, color=COR_IDEAL, linestyle='--', linewidth=1.2,
                   label=f'Speedup ideal ({br(ideal)})')
        ax.set_xscale('log')
        ax.set_xticks(ns, [str(n) for n in ns])
        ax.minorticks_off()
        ax.set_xlabel('Instruções úteis (escala log.)')
        ax.set_ylabel('Speedup O2/O1')
        ax.set_ylim(0, ideal * 1.2)
        ax.yaxis.set_major_formatter(virgula)
        ax.legend(loc='lower right', fontsize=7)
        fig.tight_layout()
        fig.savefig(os.path.join(a.saida, 'fig8_speedup_serie.png'), dpi=250)
        plt.close(fig)

    print(f'Gráficos gravados em {a.saida}/')


if __name__ == '__main__':
    main()
