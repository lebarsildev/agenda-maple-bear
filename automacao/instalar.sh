#!/bin/bash
# Instala o agente que publica a agenda sozinho. Rode uma única vez no Terminal:
#   bash ~/Documents/GitHub/agenda-maple-bear/automacao/instalar.sh
REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROTULO="com.agenda-maple-bear.publicar"
PLIST="$HOME/Library/LaunchAgents/$ROTULO.plist"
LOG="$HOME/Library/Logs/agenda-maple-bear.log"
ALVO="gui/$(id -u)"

echo "1/3  Publicando agora o que está pendente..."
AGENDA_ORIGEM=instalacao bash "$REPO/automacao/publicar.sh"
echo "     $(cat "$REPO/automacao/status-publicacao.txt" 2>/dev/null || echo 'nada pendente')"

echo "2/3  Instalando o agente de publicação automática..."
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cat > "$PLIST" <<PLIST_FIM
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$ROTULO</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$REPO/automacao/publicar.sh</string></array>
  <key>EnvironmentVariables</key><dict><key>AGENDA_ORIGEM</key><string>agente</string></dict>
  <key>WatchPaths</key>
  <array><string>$REPO/dados.enc.js</string><string>$REPO/status.json</string></array>
  <key>StartInterval</key><integer>1800</integer>
  <key>RunAtLoad</key><true/>
  <key>ThrottleInterval</key><integer>20</integer>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLIST_FIM
ANTES=$(grep -c "(agente)" "$LOG" 2>/dev/null || true)
launchctl bootout "$ALVO/$ROTULO" 2>/dev/null
launchctl bootstrap "$ALVO" "$PLIST" || { echo "     Não consegui registrar o agente (launchctl)."; exit 1; }

echo "3/3  Testando se o agente consegue acessar a pasta..."
sleep 12
DEPOIS=$(grep -c "(agente)" "$LOG" 2>/dev/null || true)
if [ "${DEPOIS:-0}" -gt "${ANTES:-0}" ] && grep "(agente)" "$LOG" | tail -1 | grep -q "OK"; then
  echo
  echo "Pronto. A partir de agora a agenda é publicada sozinha, sem pedir permissão."
  echo "Registro das publicações: $LOG"
else
  echo
  echo "O agente foi instalado, mas o macOS ainda não deixou ele ler a pasta Documentos."
  echo "Se apareceu uma janela pedindo acesso, clique em Permitir e rode este instalador de novo."
  echo "Se não apareceu: Ajustes do Sistema > Privacidade e Segurança > Acesso Total ao Disco,"
  echo "clique em +, pressione Cmd+Shift+G, digite /bin/bash, adicione e rode este instalador de novo."
  echo "Últimas linhas do registro:"
  tail -5 "$LOG" 2>/dev/null
fi
