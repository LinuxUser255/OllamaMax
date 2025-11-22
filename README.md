# OllamaMax - AI Chat Assistant

<p align="center">
  <img src="./static/images/ollama.png" alt="Ollama Logo" width="200">
</p>

<p align="center">
  <img src="./resources/images/ollama-max-home-page.png" alt="OllamaMax Interface" width="600">
</p>

> A modern, fast, and lightweight web interface for interacting with Ollama's large language models

## Quick Links

- **[Complete Documentation](./docs/README.md)** - Full setup guide, features, and model library
- **[Code Execution Flow](./docs/CODE_EXECUTION_ANALYSIS.md)** - Detailed line-by-line code analysis
- **[Mermaid Diagrams](./docs/MERMAID_FLOW_DIAGRAMS.md)** - Visual flow charts and sequence diagrams
- **[Model Pull System](./docs/MODEL_PULL_SYSTEM.md)** - Auto-download and optimization
- **[Development Notes](./docs/)** - Feature docs and TODOs

## Features

- **Modern Dark Theme UI** - ChatGPT-inspired interface
- **Real-time Communication** - WebSocket support with auto-reconnect
- **Multi-Model Support** - Switch between coding, vision, and chat models
- **Auto-Download Models** - Automatic model pulling when needed
- **Code Syntax Highlighting** - VSCode-style highlighting with copy buttons
- **Markdown Rendering** - Full markdown support for rich responses
- **Zero Dependencies Frontend** - No Node.js, no frameworks, pure HTML/CSS/JS

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Go 1.21+ with Gorilla Mux & WebSockets |
| **Frontend** | Vanilla JavaScript + marked.js + highlight.js |
| **LLM Runtime** | Ollama + langchaingo library |
| **Models** | 10+ curated LLMs (coding, vision, chat) |

## Quick Start

### 1. Install Ollama
```bash
# Linux/macOS
curl -fsSL https://ollama.com/install.sh | sh

# Or use the included script
chmod +x ollama_install_basic.sh
./ollama_install_basic.sh
```

### 2. Pull a Model
```bash
ollama pull llama3.1:8b
```

### 3. Build and Run OllamaMax
```bash
# Build the Go backend
go build -o ollamamax main.go

# Run the server
./ollamamax
```

### 4. Open in Browser
Navigate to: `http://localhost:8888`

## Supported Models

The application supports **10 carefully selected models** across different use cases:

### Coding & Development
- `qwen2.5-coder:7b` - Code generation and debugging
- `deepseek-coder:6.7b` - Algorithm and problem-solving
- `deepseek-r1` - Reasoning-focused coding
- `glm-4.6` - Multilingual code support

### Vision & Multimodal
- `qwen3-vl` - OCR, charts, diagram analysis
- `llava:7b` - Image understanding

### General Chat
- `llama3.1:8b` - Meta's balanced all-rounder (default)
- `qwen3:7b` - Long-context chat
- `gemma2:9b` - Fast and efficient
- `mistral:7b` - General purpose

### Embeddings
- `nomic-embed-text` - For RAG pipelines

**System Requirements:**
- 8GB RAM minimum for 7B models
- 16GB RAM recommended for multiple models
- GPU optional but recommended (CUDA/ROCm)

## Architecture Overview

```
┌─────────────┐      WebSocket/HTTP      ┌──────────────┐
│   Browser   │ ←───────────────────────→ │  Go Server   │
│   (JS/HTML) │                           │  :8888       │
└─────────────┘                           └──────┬───────┘
                                                 │
                                                 │ langchaingo
                                                 ▼
                                          ┌──────────────┐
                                          │    Ollama    │
                                          │   Service    │
                                          │  :11434      │
                                          └──────────────┘
```

**Key Components:**
1. **Frontend** - Model selector, chat UI, markdown renderer
2. **Go Backend** - WebSocket/HTTP handlers, model management
3. **Ollama Service** - LLM inference engine

**Data Flow:**
```
User Selects Model → JS captures selection → WebSocket sends JSON →
Go validates model → Auto-pulls if missing → Updates currentModel →
Sends query to Ollama → Receives response → Renders in UI
```

See [CODE_EXECUTION_ANALYSIS.md](./docs/CODE_EXECUTION_ANALYSIS.md) for complete execution flow with line numbers.

## Documentation Structure

```
docs/
├── README.md                      # Full user guide and setup
├── CODE_EXECUTION_ANALYSIS.md     # Line-by-line code walkthrough
├── MERMAID_FLOW_DIAGRAMS.md       # Visual flow charts
├── MODEL_PULL_SYSTEM.md           # Auto-download system
├── MODELS_ALIGNMENT.md            # Model selection UI
├── BOTTOM_INPUT_FEATURE.md        # Chat input implementation
├── UI_SPACING_IMPROVEMENTS.md     # UI/UX enhancements
├── TODO.md                        # Roadmap and planned features
└── WARP.md                        # AI agent instructions
```

## Development

### Project Structure
```
.
├── main.go                    # Go backend server
├── static/
│   ├── index.html            # Main UI
│   ├── script.js             # Frontend logic
│   ├── styles.css            # Dark theme styling
│   └── images/               # Logo assets
├── ollama_pull_and_run.sh    # Model optimization script
├── ollama_install_basic.sh   # Ollama installer
└── docs/                     # Documentation
```

### Key Files
- **main.go** (589 lines)
  - Lines 47-67: Available models array
  - Lines 127-198: HTTP router setup
  - Lines 308-404: WebSocket handler
  - Lines 451-476: Model installation check
  - Lines 479-515: Model auto-pull
  - Lines 563-588: LLM query processing

- **script.js** (589 lines)
  - Lines 24-72: WebSocket connection
  - Lines 147-268: Message rendering
  - Lines 336-381: Send message logic
  - Lines 454-484: Model selection handler

### Building
```bash
# Development build
go build -o ollamamax main.go

# Production build (optimized)
go build -ldflags="-s -w" -o ollamamax main.go
```

### Testing
```bash
# Check Ollama status
curl http://localhost:8888/api/health

# Get available models
curl http://localhost:8888/api/models

# Test chat (HTTP)
curl -X POST http://localhost:8888/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello","model_name":"llama3.1:8b"}'
```

## Features in Detail

### Auto-Pull Models
When you select a model that isn't installed, OllamaMax automatically:
1. Detects the missing model via `ollama list`
2. Shows a download progress indicator
3. Pulls the model using `ollama_pull_and_run.sh` (optimized)
4. Falls back to direct `ollama pull` if script fails
5. Updates the UI when ready

### WebSocket Communication
- Real-time bidirectional communication
- Auto-reconnect on connection loss
- Typing indicators during inference
- Fallback to HTTP if WebSocket unavailable

### Code Highlighting
- 30+ languages supported via highlight.js
- Copy buttons for individual code blocks
- Copy entire message button
- Language badges on code blocks

## Contributing

This is a personal project, but suggestions are welcome! See [docs/TODO.md](./docs/TODO.md) for planned features.

## License

This project uses Ollama, which is licensed under the MIT License.

## Related Links

- [Ollama Official Site](https://ollama.com/)
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Ollama Model Library](https://ollama.com/library)
- [langchaingo Documentation](https://github.com/tmc/langchaingo)

## Recent Changes

### November 22, 2024
- Organized all documentation into `docs/` folder
- Created comprehensive code execution flow analysis
- Added Mermaid flow diagrams (7 different visualizations)
- Documented complete architecture and data flow
- Updated README with clear navigation structure

---

**Built with Go, Ollama, and zero frontend frameworks**
