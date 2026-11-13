#!/bin/bash
# Remove o agente de publicação automática.
ROTULO="com.agenda-maple-bear.publicar"
launchctl bootout "gui/$(id -u)/$ROTULO" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/$ROTULO.plist"
echo "Agente removido. A pasta e o site não foram alterados."
