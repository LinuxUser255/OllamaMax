# OllamaMax Models Alignment

This document shows the complete alignment of models across all components of OllamaMax.

## Unified Model List (15 Models Total)

### Coding & Software Engineering (5 models)
1. `qwen2.5-coder:7b` - Python, JS, Bash expert
2. `deepseek-coder:6.7b` - Best for coding help
3. `deepseek-r1` - DeepSeek R1 reasoning model
4. `glm-4.6` - GLM 4.6 model
5. `deepseek-v3.1` - DeepSeek v3.1

### General Chat & Reasoning (4 models)
6. `llama3.1:8b` - Like ChatGPT (DEFAULT MODEL) ✓
7. `qwen3:7b` - Qwen3 general purpose
8. `gemma2:9b` - Fast & smart
9. `mistral:7b` - Lightweight & private

### Vision-Language & Multimodal (3 models)
10. `llava:7b` - Read images, PDFs
11. `moondream:1.8b` - Tiny vision model
12. `qwen3-vl` - Qwen3 Vision-Language

### Lightweight / Edge (2 models)
13. `phi3:mini` - Super fast on CPU
14. `tinyllama:1.1b` - Runs anywhere

### Embeddings & Search (1 model)
15. `nomic-embed-text` - Local RAG / search

## Component Alignment Status

### 1. HTML Dropdown (`static/index.html`)
✅ **Updated** - Contains all 15 models with proper tags and installation status indicators

### 2. Go Backend (`main.go`)
✅ **Updated** - `AVAILABLE_MODELS` array contains all 15 models
✅ **Updated** - Default model set to `llama3.1:8b`

### 3. Shell Script (`ollama_install_basic.sh`)
✅ **Updated** - Menu shows all 15 models (options A-O)
✅ **Updated** - Case statement handles all 15 models
✅ **Updated** - Proper quantization applied based on hardware detection

## Model Naming Conventions

- All models use the exact Ollama naming convention with tags
- Examples: `llama3.1:8b`, `qwen2.5-coder:7b`, `deepseek-coder:6.7b`
- Some models don't have size tags: `deepseek-r1`, `glm-4.6`, `qwen3-vl`
- Quantization is appended automatically by the shell script based on hardware

## Installation Status Indicators

The HTML dropdown shows installation status:
- ✓ = Installed and ready
- (Not Installed) = Needs to be pulled from Ollama

The Go backend will automatically offer to pull models when selected if they're not installed.

## Default Model

**llama3.1:8b** is set as the default model across all components as it's:
- Most likely to be pre-installed
- Best general-purpose balance
- Similar to ChatGPT in capabilities