#!/usr/bin/env bash
# ==============================================================================
#  OLLAMA PULL AND RUN SCRIPT FOR OLLAMAMAX
# ==============================================================================
#
#  WHAT THIS SCRIPT DOES
#  ---------------------
#  • Installs Ollama (Linux / macOS / WSL) if missing
#  • Detects OS & GPU → chooses safe quantisation
#  • Pulls and runs specified model
#  • Can be called with model name as parameter OR interactively
#
#  USAGE
#  -----
#  1. With parameter: ./ollama_pull_and_run.sh llama3.1:8b
#  2. Interactive: ./ollama_pull_and_run.sh
#
#  SUPPORTED MODELS (from OllamaMax)
#  ---------------------------------
#  Coding: qwen2.5-coder:7b, deepseek-coder:6.7b, deepseek-r1, glm-4.6, deepseek-v3.1
#  Chat: llama3.1:8b, qwen3:7b, gemma2:9b, mistral:7b
#  Vision: llava:7b, moondream:1.8b, qwen3-vl
#  Light: phi3:mini, tinyllama:1.1b
#  Embeddings: nomic-embed-text
#
# ==============================================================================

set -euo pipefail

# ---------- Pretty output ----------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()   { echo -e "${GREEN}[*] $1${NC}"; }
warn()  { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}"; exit 1; }

# ---------- 1. Install Ollama ----------
install_ollama() {
    if command -v ollama >/dev/null 2>&1; then
        log "Ollama $(ollama --version) already installed"
        return
    fi

    log "Installing Ollama..."
    case "$(uname -s)" in
        Linux*)
            # WSL or native Linux
            curl -fsSL https://ollama.com/install.sh | sh
            ;;
        Darwin*)
            if command -v brew >/dev/null 2>&1; then
                brew install ollama
                brew services start ollama
            else
                curl -fsSL https://ollama.com/install.sh | sh
            fi
            ;;
        *)
            error "Unsupported OS – only Linux/macOS/WSL"
            ;;
    esac
    log "Ollama ready!"
}

# ---------- 2. Detect hardware & quant ----------
detect_quant() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # Apple Silicon – native is fine
        DEFAULT_QUANT=""
        GPU="apple"
        warn "Apple Silicon → native precision"
        return
    fi

    # Linux / WSL
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
        DEFAULT_QUANT=":q4_0"
        GPU="cpu"
        warn "No NVIDIA GPU → using CPU + q4_0 (slower but works)"
    fi
}

# ---------- 3. Pull & run ----------
pull_and_run() {
    local tag=$1
    local name=${2:-$tag}  # Use tag as name if not provided
    
    # Remove any quantization suffix from the tag for checking
    local base_tag=$(echo "$tag" | sed 's/:q[0-9]_[0-9a-z_]*//g')
    
    if ! ollama list | grep -q "^$base_tag[[:space:]]"; then
        log "Downloading $name ..."
        ollama pull "$tag"
    else
        log "Already have $name"
    fi
    log "Model $name ready!"
    # Don't exec here - just return success
    return 0
}

# ---------- 3b. Just pull (for API usage) ----------
just_pull() {
    local model=$1
    
    # Apply quantization if needed (don't apply to models that don't need it)
    case "$model" in
        *:*) # Model already has a tag
            final_model="$model"
            ;;
        phi3:mini|tinyllama:*|moondream:*|nomic-embed-text|deepseek-r1|glm-4.6|deepseek-v3.1|qwen3-vl)
            # These models don't need quantization suffixes
            final_model="$model"
            ;;
        *)
            # Apply detected quantization
            final_model="${model}${DEFAULT_QUANT}"
            ;;
    esac
    
    log "Processing model: $final_model"
    pull_and_run "$final_model" "$model"
}

# ---------- 4. Menu ----------
show_menu() {
    cat <<EOF

   CODING & SOFTWARE ENGINEERING
   A) deepseek-coder:6.7b${DEFAULT_QUANT}     → Best for coding help
   B) qwen2.5-coder:7b${DEFAULT_QUANT}        → Python, JS, Bash
   C) deepseek-r1                            → DeepSeek R1 reasoning model
   D) glm-4.6                                → GLM 4.6 model
   E) deepseek-v3.1                          → DeepSeek v3.1

   GENERAL CHAT & WRITING
   F) llama3.1:8b${DEFAULT_QUANT}            → Like ChatGPT (DEFAULT)
   G) qwen3:7b${DEFAULT_QUANT}               → Qwen3 general purpose
   H) gemma2:9b${DEFAULT_QUANT}               → Fast & smart
   I) mistral:7b${DEFAULT_QUANT}             → Lightweight & private

   VISION-LANGUAGE & MULTIMODAL
   J) llava:7b${DEFAULT_QUANT}               → Read images, PDFs
   K) moondream:1.8b                         → Tiny vision model
   L) qwen3-vl                               → Qwen3 Vision-Language

   LIGHTWEIGHT / EDGE
   M) phi3:mini                              → Super fast on CPU
   N) tinyllama:1.1b                         → Runs anywhere

   EMBEDDINGS & SEARCH
   O) nomic-embed-text                       → Local RAG / search

EOF
}

#  MAIN

# Check if model was passed as parameter
if [[ $# -eq 1 ]]; then
    # Non-interactive mode - model passed as parameter
    MODEL_NAME="$1"
    log "OllamaMax Model Pull & Run"
    log "Model requested: $MODEL_NAME"
    
    install_ollama
    detect_quant
    
    # Pull the model
    just_pull "$MODEL_NAME"
    
    if [[ $? -eq 0 ]]; then
        log "Model $MODEL_NAME successfully pulled and ready to use!"
        exit 0
    else
        error "Failed to pull model $MODEL_NAME"
    fi
else
    # Interactive mode - show menu
    echo ""
    echo "===================================================="
    echo "   OLLAMA PULL AND RUN - OLLAMAMAX"
    echo "===================================================="
    echo ""
    
    install_ollama
    detect_quant
    show_menu
    
    read -rp "Pick a model (A-O): " choice
    choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
    
    case "$choice" in
        A) pull_and_run "deepseek-coder:6.7b${DEFAULT_QUANT}"   "deepseek-coder:6.7b" ;;
        B) pull_and_run "qwen2.5-coder:7b${DEFAULT_QUANT}"      "qwen2.5-coder:7b"    ;;
        C) pull_and_run "deepseek-r1"                           "deepseek-r1"         ;;
        D) pull_and_run "glm-4.6"                               "glm-4.6"             ;;
        E) pull_and_run "deepseek-v3.1"                         "deepseek-v3.1"       ;;
        F) pull_and_run "llama3.1:8b${DEFAULT_QUANT}"           "llama3.1:8b"         ;;
        G) pull_and_run "qwen3:7b${DEFAULT_QUANT}"              "qwen3:7b"            ;;
        H) pull_and_run "gemma2:9b${DEFAULT_QUANT}"             "gemma2:9b"           ;;
        I) pull_and_run "mistral:7b${DEFAULT_QUANT}"            "mistral:7b"          ;;
        J) pull_and_run "llava:7b${DEFAULT_QUANT}"              "llava:7b"            ;;
        K) pull_and_run "moondream:1.8b"                        "moondream:1.8b"      ;;
        L) pull_and_run "qwen3-vl"                              "qwen3-vl"            ;;
        M) pull_and_run "phi3:mini"                             "phi3:mini"           ;;
        N) pull_and_run "tinyllama:1.1b"                        "tinyllama:1.1b"      ;;
        O) pull_and_run "nomic-embed-text"                      "nomic-embed-text"    ;;
        *) error "Invalid selection – use A-O" ;;
    esac
    
    log "Ready to use! Run 'ollama run <model-name>' to start chatting."
fi
