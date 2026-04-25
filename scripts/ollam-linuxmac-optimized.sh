#!/usr/bin/env bash

# ==============================================================================
#  OLLAMA LOCAL LLM LAUNCHER
#  Customized for: Debian Workstation (RX 580) + macOS (M3 Max)
#
# ==============================================================================
#
#  PURPOSE
#  -------
#  This script provides a clean, interactive menu to pull and run one of
#  ten carefully selected Ollama models.  It automatically detects the host
#  platform (Linux or macOS) and applies the **optimal quantization** for your
#  hardware so every model fits comfortably in VRAM / unified memory.
#
#  SUPPORTED HARDWARE
#  ------------------
#  • Debian GNU/Linux (Bookworm) – AMD Ryzen 9 3900X + **RX 580 8 GB**
#  • macOS 15.6 (arm64) – Apple **M3 Max (30-core GPU)**, 36 GiB unified RAM
#
#  QUANTIZATION STRATEGY
#  ---------------------
#  | Machine   | VRAM / Memory | Default Quantization | Approx. VRAM per model |
#  |-----------|---------------|----------------------|------------------------|
#  | RX 580    | 8 GB          | :q4_0 (4-bit)        | 4 – 6 GB               |
#  | M3 Max    | ~30 GB unified| native (no quant)    | 6 – 12 GB              |
#
#  *Why q4_0 on the RX 580?*
#    4-bit quantization reduces memory footprint by ~50 % while preserving
#    excellent quality for 7-9 B models – perfect for an 8 GB card.
#
#  *Why native on M3 Max?*
#    The unified memory pool is large enough to run FP16 weights without
#    quantization.  If you prefer a middle ground, edit `DEFAULT_QUANT`
#    (e.g., `:q5_k_m`) or launch a specific tag manually:
#        ollama run qwen3-coder:8b-q5_k_m
#
#  MODEL LIST (A-J)
#  ---------------
#  CODING & SOFTWARE ENGINEERING
#    A) qwen3-coder:8b          → code gen / agents
#    B) deepseek-r1:7b          → math & logic
#    C) glm-4.6:9b              → multilingual dev
#    D) deepseek-v3.1:8b        → MoE thinking coder
#
#  VISION-LANGUAGE
#    E) qwen3-vl:7b             → OCR / charts
#
#  GENERAL CHAT & REASONING
#    F) gpt-oss:8b              → OpenAI-style
#    G) qwen3:14b               → long-context hybrid
#    H) llama3.1:8b             → 128k all-rounder
#
#  LIGHTWEIGHT / EDGE & EMBEDDINGS
#    I) gemma3:9b               → fast single-GPU
#    J) nomic-embed-text        → RAG / search
#
#  USAGE
#  -----
#  1. Save this file as `ollama-launch.sh`
#  2. Make it executable:
#        chmod +x ollama-launch.sh
#  3. Run it:
#        ./ollama-launch.sh
#
#  The script will:
#   • Detect your OS
#   • Show the menu with the correct quant suffix
#   • Pull the model if missing
#   • Launch Ollama in interactive mode
#
#  Happy local LLM hacking!
# ==============================================================================

set -euo pipefail

# ---------- Helper: pull if missing ----------
pull_if_missing() {
    local tag=$1
    local name=$2

    if ! ollama list | grep -q "^$tag[[:space:]]"; then
        echo "Downloading $name ..."
        ollama pull "$tag"
    else
        echo "Already have $name"
    fi
}

# ---------- Helper: launch ----------
run_model() {
    local tag=$1
    local name=$2
    pull_if_missing "$tag" "$name"
    echo "Launching $name ..."
    exec ollama run "$tag"
}

# ---------- Detect platform & set defaults ----------
if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS – M3 Max (≈ 30 GB unified)
    GPU="m3max"
    DEFAULT_QUANT=""                     # native fp16 works fine
else
    # Linux – RX 580 8 GB VRAM
    GPU="rx580"
    DEFAULT_QUANT=":q4_0"                # 4-bit quant fits comfortably
fi

# ---------- Model menu ----------
cat <<EOF

   CODING & SOFTWARE ENGINEERING
   A) qwen3-coder:8b${DEFAULT_QUANT}          → code gen / agents
   B) deepseek-r1:7b${DEFAULT_QUANT}          → math & logic
   C) glm-4.6:9b${DEFAULT_QUANT}              → multilingual dev
   D) deepseek-v3.1:8b${DEFAULT_QUANT}        → MoE thinking coder

   VISION-LANGUAGE
   E) qwen3-vl:7b${DEFAULT_QUANT}             → OCR / charts

   GENERAL CHAT & REASONING
   F) gpt-oss:8b${DEFAULT_QUANT}              → OpenAI-style
   G) qwen3:14b${DEFAULT_QUANT}               → long-context hybrid
   H) llama3.1:8b${DEFAULT_QUANT}             → 128k all-rounder

   LIGHTWEIGHT / EDGE & EMBEDDINGS
   I) gemma3:9b${DEFAULT_QUANT}               → fast single-GPU
   J) nomic-embed-text                        → RAG / search

EOF

read -rp "Choose (A-J): " choice
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

case "$choice" in
    A) run_model "qwen3-coder:8b${DEFAULT_QUANT}"      "qwen3-coder:8b"      ;;
    B) run_model "deepseek-r1:7b${DEFAULT_QUANT}"      "deepseek-r1:7b"      ;;
    C) run_model "glm-4.6:9b${DEFAULT_QUANT}"          "glm-4.6:9b"          ;;
    D) run_model "deepseek-v3.1:8b${DEFAULT_QUANT}"    "deepseek-v3.1:8b"    ;;
    E) run_model "qwen3-vl:7b${DEFAULT_QUANT}"         "qwen3-vl:7b"         ;;
    F) run_model "gpt-oss:8b${DEFAULT_QUANT}"          "gpt-oss:8b"          ;;
    G) run_model "qwen3:14b${DEFAULT_QUANT}"           "qwen3:14b"           ;;
    H) run_model "llama3.1:8b${DEFAULT_QUANT}"         "llama3.1:8b"         ;;
    I) run_model "gemma3:9b${DEFAULT_QUANT}"           "gemma3:9b"           ;;
    J) run_model "nomic-embed-text"                    "nomic-embed-text"    ;;
    *) echo "Invalid selection – use A-J" ; exit 1 ;;
esac

