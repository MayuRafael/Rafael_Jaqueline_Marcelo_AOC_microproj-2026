# MicroProj DCC 301 (AOC, UFRR): monociclo vs. pipeline em VHDL

Trio: Rafael da Silva, Jaqueline Braga Meneses e Marcelo Luiz de Souza.
Disciplina: DCC 301, Arquitetura e Organização de Computadores, Prof. Herbert Rocha.

O projeto compara duas organizações de um processador MIPS32 que executam o mesmo
subconjunto de instruções (`add sub addi and or slt lw sw beq break`):

- **O1**: processador monociclo, usado como referência;
- **O2**: pipeline escalar de 5 estágios (IF, ID, EX, MEM, WB) com unidade que
  **detecta** conflitos de dados, estruturais e de controle sem resolvê-los. Ao
  detectar um conflito, o processador informa tipo, PC e ciclo (`hazard_*`) e congela.

As duas organizações expõem a mesma entidade `cpu_top`, e um único testbench serve às duas.
O enunciado está em [specs/](specs/).

## Requisitos

- GHDL com suporte a VHDL-2008 (testado no GHDL 5.0.1, Ubuntu no WSL);
- GTKWave, para ver as formas de onda;
- Python 3 com matplotlib, para a Tabela 4 e os gráficos
  (`sudo apt install python3-matplotlib`).

Para conferir o ambiente: `bash scripts/verifica_ambiente.sh` (detalhes em [docs/ambiente.md](docs/ambiente.md)).

## Como reproduzir tudo (comando único)

Na raiz do repositório:

```bash
bash run_all.sh
```

O script:

1. compila a O1 e a O2, cada uma na sua biblioteca (`build/o1` e `build/o2`);
2. roda o T0 e a série S (5 a 200 instruções) nas duas organizações;
3. roda os traços de conflito TD, TE e TC na O2;
4. grava uma linha por simulação em `metricas.csv` e uma onda por simulação em `build/*.ghw`;
5. gera em `graficos/` a Tabela 4, os gráficos e as tabelas do T0.

A execução termina com `OK: todas as simulacoes terminaram como esperado.`

## Estrutura

| Pasta / arquivo | Conteúdo |
|---|---|
| `o1/` | O1 monociclo (componentes e `cpu_top`) |
| `o2/` | O2 pipeline: `cpu_top.vhd` (inclui a unidade de detecção), `components/` e `pipeline/` (registradores IF/ID, ID/EX, EX/MEM, MEM/WB) |
| `tb/tb_cpu.vhd` | testbench único das duas organizações |
| `tracos/` | traços em assembly (`.asm`), memória de instruções (`.hex`) e registradores esperados (`_esperado.txt`) |
| `scripts/gera_serie_s.py` | gera a série S (`tracos/s5` a `s200`) |
| `scripts/gera_graficos.py` | Tabela 4 e gráficos a partir do `metricas.csv` |
| `scripts/gera_tabelas_t0.py` | tabela do traço T0 e diagramas instrução × ciclo |
| `graficos/` | saídas dos dois scripts acima |
| `run_all.sh` | script único de compilação, simulação e métricas |

## Traços

| Traço | O que testa | Organizações |
|---|---|---|
| T0 | 30 instruções úteis, todas as classes da ISA, sem conflitos | O1 e O2 |
| S5 a S200 | mesmas regras do T0, com 5, 10, 20, 50, 100 e 200 instruções | O1 e O2 |
| TD | conflito de dados (RAW) | O2 |
| TE | conflito estrutural (memória unificada) | O2 |
| TC | conflito de controle (`beq` tomado) | O2 |

## Rodar um traço só e ver a onda

```bash
ghdl -r --std=08 --workdir=build/o2 tb_cpu \
     -gPROG_FILE=tracos/td.hex -gESPERA_ABORTO=true -gTIPO_ESPERADO=1 \
     --wave=build/o2_td.ghw
gtkwave build/o2_td.ghw &
```

(Rode `bash run_all.sh` antes, para compilar as duas organizações.)

## Períodos de clock

Estimados por tabela de atrasos (Patterson e Hennessy) mais 50 ps de overhead por
registrador (Harris e Harris): **O1 = 850 ps** e **O2 = 250 ps**. Para usar outros valores:
`python3 scripts/gera_graficos.py --t-o1 <ps> --t-o2 <ps>`.

## Relatório e uso de IA

O relatório (modelo SBC) descreve a metodologia, a implementação e os resultados.
O uso de IA no projeto está declarado no Apêndice C do relatório.
