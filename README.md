# 🎭 Gemini Rivals: The "Team of Rivals" Loop

[![Research Paper](https://img.shields.io/badge/arXiv-2601.14351-B31B1B.svg)](https://arxiv.org/pdf/2601.14351)

Based on the research paper **"If You Want Coherence, Orchestrate a Team of Rivals"** ([arXiv:2601.14351](https://arxiv.org/pdf/2601.14351)), this extension replaces standard AI "hallucination" with high-stakes adversarial debate.


## 🧠 Philosophy: Ruthless Coherence
Standard LLMs suffer from "self-correction blindness." **Rivals** breaks this by splitting Gemini into three hostile personas:

* **Planner:** Sets the traps (constraints).
* **Executor:** Attempts the gauntlet (implementation).
* **Critic:** Finds the flaws (auditing).

The loop utilizes a **RALPH** (Reasoning, Action, Learning from Performance Heuristics) structure. The "Learning" happens when the **Critic** rejects the work, forcing a total re-reasoning in the next turn.

---

## 📦 Installation
```bash
gemini extensions install https://github.com/OddHatter/gemini-rivals
````

---

## 🚀 Usage

### Interactive Mode

Inside the `gemini>` chat:

Bash

```
/rivals:loop "Refactor the Tuesday mic DMX routing script for OLA" --max-attempts 8
```

### Options

- `--max-attempts <N>`: Set a hard limit on how many times the rivalry will loop (Default: 5).
- The loop terminates automatically when the agent outputs `<promise>COMPLETED</promise>`.

### Advanced Routing & Logic

Use this for tasks where precision is non-negotiable:

- **Audio-over-IP:** Ensure zero-latency routing and error handling.
    
- **DMX/Lighting:** Hardened OLA daemon management and signal offsets.
    
- **System Admin:** Secure Bash/Python scripts with proper sudo-guards.
    

---

## 🛠 Technical Details

- **Architecture:** `AfterAgent` hook monitoring for the `<promise>COMPLETED</promise>` tag.
    
- **Auth:** Native terminal authentication (no API keys/env files needed).
    
- **Isolation:** Session-aware state tracking in `/tmp` to support multi-terminal workflows.
    

---

## ⚡ Built by OddHatter

Optimized for the "man of many hats"