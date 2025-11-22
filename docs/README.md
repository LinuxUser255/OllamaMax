# Ollama AI Assistant 

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Supported LLMs](#supported-llms)
- [Quickstart](#quickstart)
    - [Getting Started with Ollama AI Assistant](#getting-started-with-ollama-ai-assistant)
    - [Step 1: Install Ollama](#step-1-install-ollama)
    - [Step 2: Pull a Model](#step-2-pull-a-model)
    - [Step 3: Run the Model](#step-3-run-the-model)
    - [Step 4: Use the Shell Script](#step-4-use-the-shell-script-optional)
- [Model Library](#model-library)
- [Customize a Model](#customize-a-model)
    - [Import from GGUF](#import-from-gguf)
- [Flow Chart Diagram](#flow-chart-diagram-for-ollama-ai-assistant-application)
    - [Explanation of the Flow](#explanation-of-the-flow)



<br>


### Powered by [Ollama](https://ollama.com/)



<p align="center">
  <img src="./static/images/Ollama.com-logo.png" alt="Ollama.com-logo" width="45%">
</p>

# Overview
A sleek, modern chat interface for interacting with a variety of Ollama's large language models covering a wide variety of use cases.

This application provides a ChatGPT-inspired dark theme UI with proper code syntax highlighting and markdown support.


- Clean, responsive web interface with dark theme
- Support for multiple Ollama code models
- VSCode-style syntax highlighting for code blocks
- Markdown rendering for rich text responses
- Easy-to-use chat interface
- Ollama install and run shell script
  Located in: `use/runollam.sh`

### Tech Stack
- Go
- Java Script
- HTML
- CSS

### No web templates, frameworks or bloatware like Node.

# Features
### Supported LLMs
Here is **your exact list** (trimmed to a **maximum of 10 models**) and **sorted by category/use-case** for **local Ollama deployment**.  
Models are grouped by primary real-world use on a single machine (GPU/CPU), with brief local-run notes.

---

### **1. Coding & Software Engineering** *(Top priority for dev workflows)*
1. **qwen3-coder**  
   Alibaba's long-context coding specialist. Excellent for code generation, debugging, and agentic scripting.  
   *Local tip*: 8B runs fast on 16GB VRAM; 32B needs quantization.

2. **deepseek-r1**  
   Reasoning-focused coder rivaling O3 in math/logic. Great for algorithms and complex problem-solving.  
   *Local tip*: 7B/14B variants ideal for laptops.

3. **glm-4.6**  
   Zhipu AI’s multilingual coding beast. Strong in Python, JS, Rust, and agentic tool use.  
   *Local tip*: Use 4-bit quant for 24GB+ GPUs.

4. **deepseek-v3.1**  
   MoE with “thinking mode” toggle. Elite in competitive programming and step-by-step reasoning.  
   *Local tip*: Disable thinking mode for faster chat.

---

### **2. Vision-Language & Multimodal**
5. **qwen3-vl**  
   Best-in-class local vision model. Handles charts, diagrams, screenshots, and OCR.  
   *Local tip*: 7B fits in 12GB VRAM; perfect for document AI.

---

### **3. General Chat & Reasoning** *(Daily driver models)*
6. **gpt-oss**  
   OpenAI-style reasoning in open weights. Great for writing, brainstorming, and agent simulation.  
   *Local tip*: 8B is snappy; 70B for deep analysis.

7. **qwen3**  
   Dense + MoE hybrid. Balanced speed and intelligence. Strong multilingual and long-context chat.  
   *Local tip*: 8B/14B for daily use; 72B MoE for power users.

8. **llama3.1**  
   Meta’s gold standard. 8B for speed, 70B for depth. 128K context = perfect for full docs.  
   *Local tip*: 8B quantized = best all-rounder on 12–16GB.

---

### **4. Lightweight / Edge & Embeddings**
9. **gemma3**  
   Google’s single-GPU champ. Fast, smart, and efficient. Ideal for laptops and real-time tasks.  
   *Local tip*: 2B/9B fly on CPU+GPU; 27B needs 24GB+.

10. **nomic-embed-text**  
    Top open embedding model. 8192-token context, multimodal-ready. Use with local RAG pipelines.  
    *Local tip*: Runs in <1GB RAM. Pair with any LLM.

---

### **Final Local Run Recommendations (Your Machine)**
| Use Case | Best Model | VRAM Needed (Quantized) |
|--------|------------|-------------------------|
| **Coding Agent** | `qwen3-coder:8b` | ~10GB |
| **Vision OCR** | `qwen3-vl:7b` | ~12GB |
| **Daily Chat** | `llama3.1:8b` or `gemma3:9b` | ~8–10GB |
| **RAG/Embeddings** | `nomic-embed-text` | <1GB |

*Drop the rest (like `embeddinggemma`, `llama3.2`, `mistral`) to stay under 10 and avoid overlap.*

<br>

# Quickstart

## Getting Started with Ollama AI Assistant

This application provides a sleek interface for interacting with various Ollama models. Follow these steps to get up and running:

### Step 1: Install Ollama

If you haven't already installed Ollama, use our convenient script:

```shell
chmod +x install_ollama.sh
./install_ollama.sh
```

### Step 2: Pull a Model

To pull a model, use the following command. For example, to pull Llama 3.1:

```shell
ollama pull llama3.1
```

### Step 3: Run the Model

Once the model is pulled, you can run it interactively on the command line:

```shell
ollama run llama3.1
```

### Step 4: Use the Shell Script (Optional)

You can also use the included shell script to automate the selection and pulling of Ollama models:

```shell
chmod +x install_ollama.sh
./install_ollama.sh
```

<br>

### - _Before pulling a model number, keep in mind the memory constraints and limitations of your machine. Check the table below_

<br>

## Check the LLM details on Ollama's repo and web site:

###  _The following information is from [Ollama's GitHub](https://github.com/ollama/ollama) and is relevant to its use in this web scraper_

<br>

# Model library

**- Ollama supports a list of models available on [ollama.com/library](https://ollama.com/library 'ollama model library')**

**- Here are some example models that can be downloaded:**

| Model              | Parameters | Size  | Download                       |
| ------------------ | ---------- | ----- | ------------------------------ |
| Llama 3.1          | 8B         | 4.7GB | `ollama run llama3.1`          |
| Llama 3.1          | 70B        | 40GB  | `ollama run llama3.1:70b`      |
| Llama 3.1          | 405B       | 231GB | `ollama run llama3.1:405b`     |
| Phi 3 Mini         | 3.8B       | 2.3GB | `ollama run phi3`              |
| Phi 3 Medium       | 14B        | 7.9GB | `ollama run phi3:medium`       |
| Gemma 2            | 2B         | 1.6GB | `ollama run gemma2:2b`         |
| Gemma 2            | 9B         | 5.5GB | `ollama run gemma2`            |
| Gemma 2            | 27B        | 16GB  | `ollama run gemma2:27b`        |
| Mistral            | 7B         | 4.1GB | `ollama run mistral`           |
| Moondream 2        | 1.4B       | 829MB | `ollama run moondream`         |
| Neural Chat        | 7B         | 4.1GB | `ollama run neural-chat`       |
| Starling           | 7B         | 4.1GB | `ollama run starling-lm`       |
| Code Llama         | 7B         | 3.8GB | `ollama run codellama`         |
| Llama 2 Uncensored | 7B         | 3.8GB | `ollama run llama2-uncensored` |
| LLaVA              | 7B         | 4.5GB | `ollama run llava`             |
| Solar              | 10.7B      | 6.1GB | `ollama run solar`             |

> [!NOTE]
> You should have at least 8 GB of RAM available to run the 7B models, 16 GB to run the 13B models, and 32 GB to run the 33B models.

## Customize a model

### Import from GGUF

Ollama supports importing GGUF models in the Modelfile:

1. Create a file named `Modelfile`, with a `FROM` instruction with the local filepath to the model you want to import.

   ```
   FROM ./vicuna-33b.Q4_0.gguf
   ```

2. Create the model in Ollama

   ```
   ollama create example -f Modelfile
   ```

3. Run the model

   ```
   ollama run example
   ```


### Flow Chart Diagram of Ollama AI Assistant Application


<p align="center">
  <img src="./static/images/OllamaAPI-FlowChart.png" alt="Ollama.com-logo" width="45%">
</p>




```mermaid
flowchart TD
    A[Client Browser] -->|HTTP Request| B[Go Web Server]
    
    subgraph "Backend (Go Server)"
        B --> C{Request Type}
        
        C -->|GET /| D[Serve index.html]
        C -->|GET /api/models| E[Get Available Models]
        C -->|POST /api/chat| F[Handle Chat Request]
        C -->|GET /api/chat/ws| G[WebSocket Connection]
        C -->|GET /api/health| H[Health Check]
        
        E --> E1[Return AVAILABLE_MODELS list]
        
        F --> F1[Parse ChatMessage]
        F1 --> F2{Valid Model?}
        F2 -->|Yes| F3[Update currentModel]
        F2 -->|No| F4[Return Error]
        F3 --> F5[Process Query with LangChain]
        F5 --> F6[Return Response]
        F4 --> F6
        
        G --> G1[Establish WebSocket]
        G1 --> G2[Listen for Messages]
        G2 --> G3[Parse Message]
        G3 --> G4{Valid Model?}
        G4 -->|Yes| G5[Update currentModel]
        G4 -->|No| G6[Send Error]
        G5 --> G7[Process Query with LangChain]
        G7 --> G8[Send Response via WebSocket]
        G6 --> G8
        
        H --> H1[Check if Ollama is Running]
        H1 --> H2{Ollama Available?}
        H2 -->|Yes| H3[Return Status OK]
        H2 -->|No| H4[Return Status Error]
    end
    
    subgraph "Ollama LLM Processing"
        F5 --> I[Format Prompt with Template]
        G7 --> I
        I --> J[Initialize Ollama LLM Client]
        J --> K[Generate Response with LangChain]
        K --> L[Return Formatted Response]
    end
    
    D --> A
    E1 --> A
    F6 --> A
    G8 --> A
    H3 --> A
    H4 --> A
    L --> F5
    L --> G7
    
    subgraph "Frontend (Browser)"
        A --> M[Display UI]
        M --> N[User Selects Model]
        M --> O[User Enters Message]
        O --> P{Connection Type}
        P -->|HTTP| Q[Send POST Request]
        P -->|WebSocket| R[Send WebSocket Message]
        Q --> S[Display Response]
        R --> S
    end
```

## Explanation of the Flow

1. **Client Interaction**:
    - User accesses the application through a web browser
    - The frontend loads the UI with a model selector and chat interface
    - User can select a model from the dropdown menu and enter messages

2. **Request Handling**:
    - The Go web server handles different types of requests:
        - Serves static files (HTML, CSS, JS)
        - Provides API endpoints for models, chat, and health checks
        - Manages WebSocket connections for real-time chat

3. **Model Selection**:
    - Available models are defined in the `AVAILABLE_MODELS` array
    - The frontend displays these models in a dropdown
    - When a user selects a model, it's sent with the chat message

4. **Chat Processing**:
    - Messages can be sent via HTTP POST or WebSocket
    - The server validates the requested model
    - If valid, it updates the current model
    - The message is processed using the Ollama LLM through LangChain

5. **LLM Integration**:
    - The system formats the prompt using a template
    - Initializes the Ollama LLM client with the selected model
    - Generates a response using LangChain
    - Returns the formatted response to the client

6. **Response Handling**:
    - The response is sent back to the client
    - For HTTP requests, it's returned as JSON
    - For WebSocket connections, it's sent as a text message
    - The frontend displays the response with proper markdown formatting and syntax highlighting

This flow chart illustrates the complete lifecycle of a user interaction with the Ollama AI Assistant application, from model selection to receiving AI-generated responses.