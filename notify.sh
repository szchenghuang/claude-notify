#!/bin/bash
INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')
CWD=$(echo "$INPUT" | jq -r '.cwd' | sed "s|$HOME|~|")
SUMMARY=$(tail -50 "$TRANSCRIPT" | jq -r 'select(.type=="assistant") | .message.content[] | select(.type=="text") | .text' 2>/dev/null | tail -1 | cut -c1-80 | tr '"' "'")

if [ -n "$TMUX" ]; then
  WIN=$(tmux display-message -p '#I' 2>/dev/null || echo '?')
  SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo '')
  TERM_PROG=$(tmux show-environment TERM_PROGRAM 2>/dev/null | cut -d= -f2)
else
  TERM_PROG="$TERM_PROGRAM"
fi

case "$TERM_PROG" in
  iTerm.app)     TERM_APP="iTerm" ;;
  kitty)         TERM_APP="kitty" ;;
  Apple_Terminal) TERM_APP="Terminal" ;;
  ghostty)       TERM_APP="Ghostty" ;;
  WarpTerminal)  TERM_APP="Warp" ;;
  *)             TERM_APP="Terminal" ;;
esac

if [ -n "$TMUX" ]; then
  TITLE="Claude Code • Window $WIN • $CWD"
  EXECUTE="tmux select-window -t '${SESSION}:${WIN}'; open -a '${TERM_APP}'"
else
  TITLE="Claude Code • $CWD"
  EXECUTE="open -a '${TERM_APP}'"
fi

terminal-notifier \
  -title "$TITLE" \
  -message "$SUMMARY" \
  -execute "$EXECUTE"
