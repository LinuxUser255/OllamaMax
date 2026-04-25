#!/usr/bin/env bash

# ==============================================================================
#  OLLAMA QUICK-START INSTALLER & LAUNCHER – FOR THE AVERAGE USER
#  Designed for: Everyday laptops, desktops, and home PCs (2025)
# ==============================================================================
#
#  WHO THIS IS FOR
#  ---------------
#  • You have a **modern laptop or desktop** (2018 or newer)
#  • You want **AI chat, coding help, or document analysis** locally
#  • You **don’t want to configure anything** — just run and go
#
#  SUPPORTED HARDWARE (THE "AVERAGE" 2025 SETUP)
#  ---------------------------------------------
#  | Device Type       | Typical GPU / RAM | Recommended Quantization |
#  |-------------------|-------------------|---------------------------|
#  | **Windows Laptop** | Intel Iris / AMD iGPU / RTX 3050 4–6 GB | `:q4_0` (4-bit) |
#  | **MacBook Air/Pro** | Apple M1/M2/M3 (8–16 GB unified) | `native` or `:q5_k_m` |
#  | **Linux Desktop**  | GTX 1660 / RTX 3060 6–8 GB | `:q4_0` or `:q5_k_m` |
#  | **Low-End / CPU-Only** | No GPU, 16+ GB RAM | `:q4_0` (CPU offload) |
#
#  MODELS INCLUDED (A–P) – BEST FOR DAILY USE
#  -------------------------------------------
#  CODING & PROBLEM SOLVING
#    A) deepseek-coder:6.7b   → Write, debug, explain code fast
#    B) qwen2.5-coder:7b      → Great for Python, JS, Bash
#    P) qwen2.5-coder:32b-instruct → Elite coding (Claude-level refactors)

#  GENERAL CHAT & WRITING
#    C) llama3.1:8b           → Best all-rounder (like ChatGPT)
#    D) gemma2:9b             → Fast, smart, runs on almost anything
#    E) mistral:7b            → Lightweight, snappy, private

#  DOCUMENT & IMAGE ANALYSIS
#    F) llava:7b              → Describe photos, read PDFs, OCR
#    G) moondream:1.8b        → Tiny vision model for edge devices

#  EMBEDDINGS & SEARCH (RAG)
#    H) nomic-embed-text      → Turn docs into searchable vectors

#  FUN / CREATIVE
#    I) phi3:mini             → Super fast on CPU, great for jokes
#    J) tinyllama:1.1b        → Runs on a potato — perfect for testing

#  INSTALLS & RUNS IN ONE COMMAND
#  -------------------------------
#  1. Save this file: `ollama-go.sh`
#  2. Make executable: `chmod +x ollama-go.sh`
#  3. Run: `./ollama-go.sh`
#
#  It will:
#   • Install Ollama (if missing)
#   • Detect your OS & GPU
#   • Pick the **best quantization** automatically
#   • Show a clean menu
#   • Download & run your model
#
#  NO CONFIG. NO DOCKER. NO HEADACHES.
#
# How to use One-Liner
# curl -fsSL https://bit.ly/ollama-go | bash
#
# Download & Run a Model
# wget -O ollama-go.sh https://bit.ly/ollama-go && chmod +x ollama-go.sh && ./ollama-go.sh
# ==============================================================================

set -euo pipefail

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[*] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}"; exit 1; }

# ---------- 1. INSTALL OLLAMA IF MISSING ----------
install_ollama() {
    if command -v ollama >/dev/null 2>&1; then
        log "Ollama already installed: $(ollama --version)"
        return
    fi

    log "Installing Ollama..."
    case "$(uname -s)" in
        Linux*)
            curl -fsSL https://ollama.com/install.sh | sh
            ;;
        Darwin*)
            if command -v brew >/dev/null 2>&1; then
                brew install ollama
                log "Starting Ollama service..."
                brew services start ollama
            else
                curl -fsSL https://ollama.com/install.sh | sh
            fi
            ;;
        *)
            error "Unsupported OS. Only Linux and macOS supported."
            ;;
    esac

    log "Ollama installed successfully!"
}

# ---------- 2. DETECT HARDWARE & SET QUANT ----------
detect_quant() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS: M1/M2/M3 — use native or q5
        if [[ "$(sysctl -n machdep.cpu.brand_string)" == *"Apple"* ]]; then
            GPU="apple_silicon"
            DEFAULT_QUANT=""  # native FP16
            warn "Using native precision (fast on M-series)"
        else
            DEFAULT_QUANT=":q5_k_m"
        fi
    else
        # Linux: check for NVIDIA
        if command -v nvidia-smi >/dev/null 2>&1; then
            VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
            if (( VRAM >= 6000 )); then
                DEFAULT_QUANT=":q5_k_m"
                GPU="nvidia_6gb+"
            else
                DEFAULT_QUANT=":q4_0"
                GPU="nvidia_low"
            fi
        else
            # CPU-only or AMD/Intel iGPU
            DEFAULT_QUANT=":q4_0"
            GPU="cpu_only"
            warn "No NVIDIA GPU detected — using CPU + q4_0 (slower but works!)"
        fi
    fi
}

# ---------- 3. PULL & RUN MODEL ----------
pull_and_run() {
    local tag=$1
    local name=$2

    if ! ollama list | grep -q "^$tag[[:space:]]"; then
        log "Downloading $name..."
        ollama pull "$tag"
    else
        log "Already have $name"
    fi

    log "Launching $name... (Ctrl+C to stop)"
    exec ollama run "$tag"
}

show_menu() {
    cat <<EOF

   CODING & PROBLEM SOLVING
   A) deepseek-coder:6.7b${DEFAULT_QUANT}     → Best for coding help
   B) qwen2.5-coder:7b${DEFAULT_QUANT}        → Python, JS, Bash
   P) qwen2.5-coder:32b-instruct${DEFAULT_QUANT} → Elite coding (Claude-level refactors)

   GENERAL CHAT & WRITING
   C) llama3.1:8b${DEFAULT_QUANT}            → Like ChatGPT (DEFAULT)
   D) gemma2:9b${DEFAULT_QUANT}               → Fast & smart
   E) mistral:7b${DEFAULT_QUANT}             → Lightweight & private
   K) qwen3:7b${DEFAULT_QUANT}               → Qwen3 general purpose

   DOCUMENT & IMAGE ANALYSIS
   F) llava:7b${DEFAULT_QUANT}               → Read images, PDFs
   G) moondream:1.8b                         → Tiny vision model
   O) qwen3-vl                               → Qwen3 Vision-Language

   LIGHTWEIGHT / EDGE
   H) phi3:mini                              → Super fast on CPU
   I) tinyllama:1.1b                         → Runs anywhere

   EMBEDDINGS & SEARCH
   J) nomic-embed-text                       → Local RAG / search

EOF
}

#  MAIN EXECUTION

echo ""
echo "================================================="
echo "   OLLAMA QUICK-START – FOR EVERYDAY USERS     "
echo "================================================="
echo ""

install_ollama
detect_quant

show_menu

read -rp "Choose a model (A-P): " choice
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

case "$choice" in
    A) pull_and_run "deepseek-coder:6.7b${DEFAULT_QUANT}"      "deepseek-coder:6.7b"      ;;
    B) pull_and_run "qwen2.5-coder:7b${DEFAULT_QUANT}"         "qwen2.5-coder:7b"         ;;
    C) pull_and_run "llama3.1:8b${DEFAULT_QUANT}"              "llama3.1:8b"              ;;
    D) pull_and_run "gemma2:9b${DEFAULT_QUANT}"                "gemma2:9b"                ;;
    E) pull_and_run "mistral:7b${DEFAULT_QUANT}"               "mistral:7b"               ;;
    F) pull_and_run "llava:7b${DEFAULT_QUANT}"                 "llava:7b"                 ;;
    G) pull_and_run "moondream:1.8b"                           "moondream:1.8b"           ;;
    H) pull_and_run "phi3:mini"                                "phi3:mini"                ;;
    I) pull_and_run "tinyllama:1.1b"                           "tinyllama:1.1b"           ;;
    J) pull_and_run "nomic-embed-text"                         "nomic-embed-text"         ;;
    K) pull_and_run "qwen3:7b${DEFAULT_QUANT}"                 "qwen3:7b"                 ;;
    L) pull_and_run "deepseek-r1"                              "deepseek-r1"              ;;
    M) pull_and_run "glm-4.6"                                  "glm-4.6"                  ;;
    N) pull_and_run "deepseek-v3.1"                            "deepseek-v3.1"            ;;
    O) pull_and_run "qwen3-vl"                                 "qwen3-vl"                 ;;
    P) pull_and_run "qwen2.5-coder:32b-instruct${DEFAULT_QUANT}" "Qwen 2.5-Coder-32B-Instruct" ;;
    Q) pull_and_run "qwen2.5-coder:32b-instruct-q4_K_M"        "Qwen 2.5-Coder-32B (Quantized)" ;;  # Lighter variant
    *) error "Invalid choice. Use A–P." ;;
esac