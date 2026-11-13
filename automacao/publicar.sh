#!/bin/bash
# Publica no GitHub Pages tudo o que mudou nesta pasta (commit + push).
# Roda sozinho no Mac: o agente instalado por instalar.sh chama este script
# sempre que dados.enc.js ou status.json mudam, e a cada 30 minutos como reserva.
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$HOME/Library/Logs/agenda-maple-bear.log"
STATUS="$REPO/automacao/status-publicacao.txt"
ORIGEM="${AGENDA_ORIGEM:-manual}"

agora() { date "+%d/%m/%Y %H:%M:%S"; }
ocultar() { sed -E 's#https://[^@/ ]+@#https://***@#g'; }
falha() {
  echo "$(agora) ERRO ($ORIGEM): $1" | ocultar | tee -a "$LOG" > "$STATUS"
  exit 1
}

cd "$REPO" || exit 1
mkdir -p "$(dirname "$LOG")"

# Espera a gravação do arquivo terminar e limpa travas esquecidas por execuções interrompidas.
sleep 3
find .git -name "*.lock" -mmin +2 -delete 2>/dev/null
find .git/objects -name "tmp_obj_*" -mmin +10 -delete 2>/dev/null

git add -A 2>>"$LOG" || falha "git add falhou"

if ! git diff --cached --quiet; then
  if git diff --cached --name-only | grep -qvE '^(dados\.enc\.js|status\.json)$'; then
    MSG="Atualiza site"
  else
    MSG="Atualiza dados"
  fi
  if [ -z "$(git config user.email)" ]; then
    IDENT=(-c user.name="Agenda Maple Bear" -c user.email="agenda-maple-bear@users.noreply.github.com")
  else
    IDENT=()
  fi
  git "${IDENT[@]}" commit -q -m "$MSG $(date '+%d/%m %H:%M')" 2>>"$LOG" || falha "git commit falhou"
fi

if [ -z "$(git log origin/main..HEAD --oneline 2>/dev/null)" ]; then
  echo "$(agora) OK ($ORIGEM): nada novo para publicar" >> "$LOG"
  [ -f "$STATUS" ] && grep -q "ERRO" "$STATUS" && echo "$(agora) OK ($ORIGEM): nada pendente" > "$STATUS"
  exit 0
fi

SAIDA="$(git push origin HEAD:main 2>&1)"
if [ $? -ne 0 ]; then
  # O GitHub pode ter commits que esta pasta ainda não tem: traz e tenta de novo, sem forçar nada.
  git pull --rebase -q origin main >>"$LOG" 2>&1
  SAIDA="$(git push origin HEAD:main 2>&1)" || falha "git push falhou: $(echo "$SAIDA" | tail -2 | tr '\n' ' ')"
fi

echo "$(agora) OK ($ORIGEM): publicado $(git log -1 --format=%s)" | tee -a "$LOG" > "$STATUS"
