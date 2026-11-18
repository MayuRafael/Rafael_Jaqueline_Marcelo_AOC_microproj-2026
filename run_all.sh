#!/usr/bin/env bash
# run_all.sh : comando unico do MicroProj (R7).
# Compila O1 e O2 (cada uma na sua workdir), roda todos os tracos e gera metricas.csv.
# Uso (no Ubuntu/WSL, na raiz do repositorio):  bash run_all.sh
#
# Uso de IA: script escrito com apoio do Claude (Anthropic); declarar no Apendice C.
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$RAIZ"

STD="--std=08"
CSV="metricas.csv"
FALHAS=0

command -v ghdl >/dev/null 2>&1 || { echo "ERRO: ghdl nao encontrado (veja docs/ambiente.md)"; exit 1; }

# ---------------------------------------------------------------------------
# Tracos limpos: rodam em O1 e em O2 e precisam terminar em done, sem erros.
#   nome do traco (sem extensao) ; o .hex e o _esperado.txt ficam em tracos/
# ---------------------------------------------------------------------------
TRACOS_LIMPOS=(t0 s5 s10 s20 s50 s100 s200)

# ---------------------------------------------------------------------------
# Tracos de conflito: rodam so em O2 e precisam abortar com o tipo certo.
#   nome ; tipo esperado (1 dados, 2 estrutural, 3 controle) ; MEM_UNIFICADA ; hazard_pc esperado (-1 = nao conferir)
# ---------------------------------------------------------------------------
TRACOS_CONFLITO=(
  "td;1;false;-1"
  "te;2;true;-1"
  "tc;3;false;-1"
)

# Compila uma organizacao. ghdl -i importa os arquivos e ghdl -m resolve a ordem
# de compilacao sozinho (o processador pode vir antes da ULA em ordem alfabetica).
compila() {
  local org="$1" wd="build/$1"
  mkdir -p "$wd"
  rm -f "$wd"/*.cf
  echo "== [$org] compilando $org/*.vhd + tb/tb_cpu.vhd"
  ghdl -i $STD --workdir="$wd" "$org"/*.vhd tb/tb_cpu.vhd || return 1
  ghdl -m $STD --workdir="$wd" tb_cpu >/dev/null || return 1
}

# Roda um traco: roda <org> <num_slots> <traco> [generics extras...]
roda() {
  local org="$1" slots="$2" traco="$3"; shift 3
  local hex="tracos/$traco.hex" esp="tracos/${traco}_esperado.txt"
  if [[ ! -f "$hex" ]]; then
    echo "   (pulando $traco em $org: $hex nao existe)"
    return 0
  fi
  [[ -f "$esp" ]] || esp="tracos/vazio_esperado.txt"
  local saida
  saida=$(ghdl -r $STD --workdir="build/$org" tb_cpu \
      -gPROG_FILE="$hex" -gESPERADO_FILE="$esp" \
      -gORG_NOME="${org^^}" -gNUM_SLOTS="$slots" "$@" \
      --wave="build/${org}_${traco}.ghw" 2>&1)
  local rc=$?
  echo "$saida" | grep -E "fim da simulacao|ABORTO|error" | sed 's/^.*(report [a-z]*): /   /'
  if [[ $rc -ne 0 ]] || echo "$saida" | grep -q "(report error)"; then
    FALHAS=$((FALHAS + 1))
  fi
}

# metricas.csv novo a cada execucao, com cabecalho
echo "org;programa;ciclos;instrucoes;CPI;IPC;ocupacao;erros" > "$CSV"
: > tracos/vazio_esperado.txt 2>/dev/null || true

# ----------------------------- O1: monociclo ------------------------------
if compila o1; then
  for t in "${TRACOS_LIMPOS[@]}"; do
    roda o1 1 "$t"
  done
else
  echo "ERRO: falha ao compilar O1"; FALHAS=$((FALHAS + 1))
fi

# ----------------------------- O2: pipeline -------------------------------
if compgen -G "o2/*.vhd" >/dev/null; then
  if compila o2; then
    for t in "${TRACOS_LIMPOS[@]}"; do
      roda o2 5 "$t"
    done
    for item in "${TRACOS_CONFLITO[@]}"; do
      IFS=';' read -r t tipo memu pc <<< "$item"
      roda o2 5 "$t" -gESPERA_ABORTO=true -gTIPO_ESPERADO="$tipo" \
           -gMEM_UNIFICADA="$memu" -gPC_ESPERADO="$pc"
    done
  else
    echo "ERRO: falha ao compilar O2"; FALHAS=$((FALHAS + 1))
  fi
else
  echo "== [o2] sem arquivos .vhd em o2/ ainda: pulando O2"
fi

rm -f tracos/vazio_esperado.txt

echo
echo "== metricas.csv"
column -t -s ';' "$CSV" 2>/dev/null || cat "$CSV"
echo
if [[ $FALHAS -eq 0 ]]; then
  echo "OK: todas as simulacoes terminaram como esperado."
else
  echo "ATENCAO: $FALHAS simulacao(oes) com erro (veja as mensagens acima)."
  exit 1
fi
