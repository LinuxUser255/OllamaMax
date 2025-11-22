# TODO

# Two main things

1. Update the README.md according to the specs below, (the install shell scripts reflect this)
2. Augment the User Interfact according to the specs listed below.

1.
## Update the README.md to reflect the LLM list and categories

Here is **your exact list** (trimmed to a **maximum of 10 models**) and **sorted by category/use-case** for **local Ollama deployment**.  
Models are grouped by primary real-world use on a single machine (GPU/CPU), with brief local-run notes.

(all of the ollama install shell scripts adhear to this categorigazation)

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


2.
# UI augmentation
UI needs to look exactly like Grok, but

Inplace of the text "SuperGrok", put "OllamaMax"

and use the Ollam Logo instead of the Grok logo

the Grok UI image is located in `/home/linux/Projects/Bots/OllamaBots/OllamaMax/resources/images/Grok-Super-UI.png`

