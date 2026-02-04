#!/bin/bash

# 1. Configuration: Default to 5 attempts
MAX_ITERATIONS=5

# 2. Extract --max-attempts flag from the conversation history
# We look for the number following the flag in the user's initial prompt
DETECTED_MAX=$(gemini-cli history --limit 10 --format json | grep -oP '(?<=--max-attempts )[0-9]+' | head -1)

if [ ! -z "$DETECTED_MAX" ]; then
  MAX_ITERATIONS=$DETECTED_MAX
fi

# 3. Check if the AI has finished its work
LAST_OUTPUT=$(gemini-cli last-output)

if [[ "$LAST_OUTPUT" == *"<promise>COMPLETED</promise>"* ]]; then
  echo "✅ Coherence achieved. Terminating loop." >&2
  rm -f "/tmp/rivals_state_$GEMINI_SESSION_ID"
  exit 0
fi

# 4. State Management (using a unique Session ID)
STATE_FILE="/tmp/rivals_state_$GEMINI_SESSION_ID"
ITERATION=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
ITERATION=$((ITERATION + 1))

# 5. Iteration Guard
if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
  echo "⚠️ Max attempts ($MAX_ITERATIONS) reached without coherence. Stopping." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# 6. Save State and Continue the Rivalry
echo "$ITERATION" > "$STATE_FILE"
echo "🔄 Rivalry Round $ITERATION of $MAX_ITERATIONS..." >&2

# Force the CLI to trigger another turn
gemini-cli continue --system "The Critic has rejected the previous output. Analyze the flaws, refine the work, and only output the completion promise when perfect."