# Agenda Escolar Maple Bear 🐻🍁

Painel da família para acompanhar aulas do dia, tarefas, comunicados e calendário (fonte: Toddle).
Os dados são criptografados (AES-256-GCM): o conteúdo só é legível com a senha da família.

## Como a atualização funciona

1. Três vezes ao dia (12h30, 15h30 e 18h30) uma tarefa agendada lê o Toddle e grava `dados.enc.js`
   (conteúdo novo) e `status.json` (horário da verificação) nesta pasta.
2. Um agente no Mac (`automacao/publicar.sh`, chamado pelo launchd) percebe a mudança e faz
   `commit + push` para o GitHub Pages.
3. O site busca os dados novos sozinho quando é aberto ou volta para a tela.

## Instalar o agente (uma única vez)

```
bash ~/Documents/GitHub/agenda-maple-bear/automacao/instalar.sh
```

Registro das publicações: `~/Library/Logs/agenda-maple-bear.log`.
Para remover: `bash automacao/desinstalar.sh`.
