#!/bin/bash

# 1. Configuration: Default to 5 attempts
MAX_ITERATIONS=5

# 2. Extract --max-attempts flag from the conversation history
# We look for the number following the flag in the user's initial prompt
DETECTED_MAX=$(gemini-cli history --limit 10 --format json 2>/dev/null | grep -oP '(?<=--max-attempts )[0-9]+' | head -1)

if [ ! -z "$DETECTED_MAX" ]; then
  MAX_ITERATIONS=$DETECTED_MAX
fi

# 3. Check if the AI has finished its work
LAST_OUTPUT=$(gemini-cli last-output 2>/dev/null)

if [[ "$LAST_OUTPUT" == *"<promise>COMPLETED</promise>"* ]]; then
  echo "✅ Coherence achieved. Terminating loop." >&2
  rm -f "/tmp/rivals_state_$GEMINI_SESSION_ID"
  rm -f "/tmp/rivals_prompt_$GEMINI_SESSION_ID"
  exit 0
fi

# 4. State Management (using a unique Session ID)
STATE_FILE="/tmp/rivals_state_$GEMINI_SESSION_ID"
PROMPT_FILE="/tmp/rivals_prompt_$GEMINI_SESSION_ID"

ITERATION=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

# If this is the first iteration, try to save the original prompt
if [ "$ITERATION" -eq 0 ]; then
    # Try to get the original prompt from history
    ORIGINAL_PROMPT=$(gemini-cli history --limit 1 --format json 2>/dev/null | jq -r '.[0].content' 2>/dev/null)
    if [ -z "$ORIGINAL_PROMPT" ] || [ "$ORIGINAL_PROMPT" == "null" ]; then
        ORIGINAL_PROMPT="[Original Task]"
    fi
    echo "$ORIGINAL_PROMPT" > "$PROMPT_FILE"
else
    ORIGINAL_PROMPT=$(cat "$PROMPT_FILE" 2>/dev/null)
fi

ITERATION=$((ITERATION + 1))

# 5. Iteration Guard
if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
  echo "⚠️ Max attempts ($MAX_ITERATIONS) reached without coherence. Stopping." >&2
  rm -f "$STATE_FILE"
  rm -f "$PROMPT_FILE"
  exit 0
fi

# 6. Save State
echo "$ITERATION" > "$STATE_FILE"
echo "🔄 Rivalry Round $ITERATION of $MAX_ITERATIONS..." >&2

# 7. Construct the next prompt with feedback and clear context
# We use jq to safely construct the JSON and ensure memory is cleared.
REASON="The Critic has rejected the previous output. Analyze the flaws, refine the work, and only output the completion promise when perfect.

Original Task:
$ORIGINAL_PROMPT

Previous Output (for context, since memory is being cleared):
$LAST_OUTPUT"

jq -n \
  --arg reason "$REASON" \
  --arg systemMessage "🔄 Rivalry Round $ITERATION starting with fresh memory..." \
  '{
    decision: "deny",
    reason: $reason,
    systemMessage: $systemMessage,
    hookSpecificOutput: {
      clearContext: true
    }
  }'

exit 0
