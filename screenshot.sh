#!/bin/bash
# Creates a fake notification and captures a screenshot of it

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCREENSHOT_OUT="${SCRIPT_DIR}/screenshot.png"
TRANSCRIPT_FILE=$(mktemp /tmp/claude-notify-transcript.XXXXXX)

# Write a fake transcript with an assistant message
echo '{"type":"assistant","message":{"content":[{"type":"text","text":"All done! The task has been completed successfully."}]}}' > "$TRANSCRIPT_FILE"

# Build the fake hook input
INPUT=$(jq -n \
  --arg transcript "$TRANSCRIPT_FILE" \
  --arg cwd "$SCRIPT_DIR" \
  '{transcript_path: $transcript, cwd: $cwd}')

# Trigger the notification
echo "$INPUT" | bash "${SCRIPT_DIR}/notify.sh"

# Wait for notification banner to appear
sleep 2

# Capture top-right corner (notification zone): x=1330 y=0 w=398 h=130
screencapture -R 1300,20,428,160 -x "$SCREENSHOT_OUT"

rm -f "$TRANSCRIPT_FILE"
echo "Saved to $SCREENSHOT_OUT"
