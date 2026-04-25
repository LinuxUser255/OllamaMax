# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

OllamaMax is a web-based chat interface for interacting with Ollama LLM models. It's a Go backend with vanilla JavaScript/HTML/CSS frontend that provides:
- ChatGPT-inspired dark theme UI with VSCode-style syntax highlighting
- WebSocket real-time chat and HTTP REST API endpoints
- Dynamic model switching and automatic model pulling
- Markdown rendering with code block support

**Tech Stack**: Go (with gorilla/mux, gorilla/websocket, langchaingo), vanilla JavaScript, HTML, CSS. No web frameworks or Node.js.

## Architecture

### Backend (Go)
- **main.go**: Monolithic server with all HTTP handlers, WebSocket logic, and LLM integration via langchaingo
- **intermal/*** (note: typo in dir name): Placeholder packages (currently empty stubs for future modularization)
  - `api/`: Future REST API handlers
  - `auth/`: Future authentication middleware
  - `config/`: Future configuration management
  - `db/`: Future database integration
  - `ollama/`: Future Ollama client abstraction

### Frontend
- **static/index.html**: Main chat UI with model selector dropdown
- **static/script.js**: WebSocket client, markdown rendering (marked.js), syntax highlighting (highlight.js)
- **static/styles.css**: Dark theme styling

### Communication Flow
1. Client connects via WebSocket (`/api/chat/ws`) on page load
2. User selects model from dropdown and sends message
3. Server validates model availability via `ollama list` CLI
4. If model missing, offers to pull it via `resources/run_ollama.sh`
5. Query processed through langchaingo → Ollama → response streamed back
6. Frontend renders markdown with syntax highlighting

## Common Commands

### Development

**Build and run the server:**
```bash
go run main.go
```
Server starts on `http://localhost:8888`

**Install dependencies:**
```bash
go mod download
go mod tidy
```

**Check for Ollama service:**
```bash
ollama list
```

### Testing Ollama Models

**Pull a model manually:**
```bash
ollama pull llama3.1:8b
```

**Run model interactively (CLI):**
```bash
ollama run llama3.1:8b
```

**Use the provided shell scripts:**
```bash
# Interactive menu for model selection
./resources/run_ollama.sh

# Automated install scripts for different use cases
./ollama_install_basic.sh          # For average users/laptops
./ollama_install_general_purpose.sh # General purpose models
./ollam-linuxmac-optimized.sh       # Linux/Mac optimized
```

### Project Structure Commands

**View available API endpoints:**
- `GET /` → Serve index.html
- `GET /api` → API status
- `GET /api/models` → List available models (from `AVAILABLE_MODELS` array)
- `GET /api/models/installed-models` → List installed Ollama models
- `POST /api/chat` → HTTP chat endpoint
- `GET /api/chat/ws` → WebSocket chat endpoint
- `POST /api/models/pull` → Pull new model
- `GET /api/health` → Check if Ollama service is running

## Development Notes

### Model Management
- `AVAILABLE_MODELS` array in main.go defines the model dropdown list
- Default model: `ollama3:8b` (set in `DEFAULT_MODEL` const)
- `currentModel` global variable tracks active model
- Models auto-added to `AVAILABLE_MODELS` if detected via `ollama list` but not in predefined list

### Frontend-Backend Contract
**WebSocket/HTTP message format:**
```json
{
  "message": "user query",
  "model_name": "llama3.1:8b"
}
```

**Response format:**
```json
{
  "response": "LLM response text",
  "action": "pull:model-name" // Optional, triggers model pull prompt
}
```

### Known Issues / TODO
See `TODO.md` for planned work:
1. Update README.md with new model categorization
2. Redesign UI to match Grok-style interface (reference: `resources/images/Grok-Super-UI.png`)
   - Replace "SuperGrok" with "OllamaMax"
   - Use Ollama logo instead of Grok logo

### Code Style
- Go: Standard Go formatting (`gofmt` applied automatically)
- JavaScript: ES6+ syntax, no transpilation
- No linting/formatting tools configured (no Makefile, no CI/CD)

### Ollama Integration
- Uses `langchaingo` library (`github.com/tmc/langchaingo`) for LLM calls
- System template in `SystemTemplate` const instructs model to use markdown formatting
- Temperature set to 0.7 for balanced creativity
- 60-second timeout on LLM calls

### Port Configuration
- Server port hardcoded to `8888` in `main.go` (const `PORT`)
- WebSocket URL: `ws://localhost:8888/api/chat/ws`
- API URL: `http://localhost:8888/api/chat`

## Recommended Model Categories

Per `TODO.md` and install scripts, prioritize these model groupings:

1. **Coding & Software Engineering**: qwen3-coder, deepseek-r1, glm-4.6, deepseek-v3.1
2. **Vision-Language & Multimodal**: qwen3-vl
3. **General Chat & Reasoning**: gpt-oss, qwen3, llama3.1
4. **Lightweight / Edge & Embeddings**: gemma3, nomic-embed-text

## Shell Script Development

When writing or modifying shell scripts in this repo (install/run scripts), follow these principles from user rules:
- Use POSIX-compatible Bash patterns
- Prefer built-ins over external commands
- Set `set -euo pipefail` for robustness
- Quote all variables: `"$var"`
- Use functions for modularity
- Parallel execution for model downloads: use background jobs (`&`) with `wait` and job limits
