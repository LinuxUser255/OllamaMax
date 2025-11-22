# OllamaMax - Detailed Code Execution Analysis

## Table of Contents
1. [Execution Flow Overview](#execution-flow-overview)
2. [User Model Selection Flow](#user-model-selection-flow)
3. [Message Processing Flow](#message-processing-flow)
4. [Code Block Analysis](#code-block-analysis)
5. [Critical Integration Points](#critical-integration-points)

---

## Execution Flow Overview

### Visual Execution Path
```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERFACE LAYER                         │
│  Location: static/index.html + static/script.js                 │
│                                                                 │
│  ┌─────────────────┐                                           │
│  │  Model Dropdown │  Lines: index.html:96-113                 │
│  │  (Select)       │         script.js:454-484                 │
│  └────────┬────────┘                                           │
│           │ User selects model (e.g., "qwen2.5-coder:7b")     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │  Event Handler  │  script.js:454 (change event listener)   │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ├──► Check if "(Not Installed)" in option text       │
│           │    script.js:460                                   │
│           │                                                     │
│           └──► Store selection in modelSelect.value            │
│                script.js:341                                   │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ User clicks Send Button
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              JAVASCRIPT MESSAGE PREPARATION                     │
│  Location: static/script.js                                     │
│                                                                 │
│  sendMessage() Function - Lines 336-381                        │
│                                                                 │
│  Block 1: Get User Input & Model                               │
│  ┌─────────────────────────────────────────────────┐          │
│  │ const selectedModel = modelSelect.value;        │  Line 341│
│  │ // Value: "qwen2.5-coder:7b"                    │          │
│  └─────────────────────────────────────────────────┘          │
│                                                                 │
│  Block 2: Check WebSocket State                                │
│  ┌─────────────────────────────────────────────────┐          │
│  │ if (isConnected && socket.readyState === 1) {   │  Line 345│
│  │   // WebSocket is OPEN and ready                │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼ TRUE PATH (WebSocket Available)                    │
│  ┌─────────────────────────────────────────────────┐          │
│  │ socket.send(JSON.stringify({                    │  Line 347│
│  │   message: message,                             │  Line 348│
│  │   model_name: selectedModel                     │  Line 349│
│  │ }));                                             │  Line 350│
│  │                                                  │          │
│  │ // Sends JSON string:                           │          │
│  │ // {"message":"explain this code",              │          │
│  │ //  "model_name":"qwen2.5-coder:7b"}            │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ WebSocket Frame Transmission
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  GO BACKEND RECEIVER                            │
│  Location: main.go                                              │
│                                                                 │
│  handleWebSocket() Function - Lines 308-404                    │
│                                                                 │
│  Block 1: Read WebSocket Message                               │
│  ┌─────────────────────────────────────────────────┐          │
│  │ messageType, p, err := conn.ReadMessage()       │  Line 325│
│  │ // p contains: []byte of JSON string            │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Unmarshal JSON to Go Struct                          │
│  ┌─────────────────────────────────────────────────┐          │
│  │ var chatMsg ChatMessage                         │  Line 334│
│  │ if err := json.Unmarshal(p, &chatMsg); ... {    │  Line 335│
│  │   // chatMsg.Message = "explain this code"      │          │
│  │   // chatMsg.ModelName = "qwen2.5-coder:7b"     │          │
│  │ }                                                │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 3: Model Validation Check                               │
│  ┌─────────────────────────────────────────────────┐          │
│  │ if chatMsg.ModelName != "" &&                   │  Line 352│
│  │    chatMsg.ModelName != currentModel {          │          │
│  │   // New model requested, need to validate      │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 4: Check Model Installation                             │
│  ┌─────────────────────────────────────────────────┐          │
│  │ if !checkModelInstalled(chatMsg.ModelName) {    │  Line 354│
│  │   // Model NOT found locally                    │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼ Model NOT Installed Path                           │
│  ┌─────────────────────────────────────────────────┐          │
│  │ statusMsg := fmt.Sprintf(                       │  Line 359│
│  │   "Model %s is not installed. Pulling...",      │          │
│  │   chatMsg.ModelName)                            │          │
│  │                                                  │          │
│  │ conn.WriteMessage(websocket.TextMessage,        │  Line 360│
│  │                   []byte(statusMsg))            │          │
│  │ // Sends notification to frontend               │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 5: Initiate Model Pull                                  │
│  ┌─────────────────────────────────────────────────┐          │
│  │ _, pullErr := pullOllamaModel(chatMsg.ModelName)│ Line 366│
│  │ // Triggers model download process              │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Execute Shell Command
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  MODEL PULL FUNCTION                            │
│  Location: main.go                                              │
│                                                                 │
│  pullOllamaModel() Function - Lines 479-515                    │
│                                                                 │
│  Block 1: Setup Shell Command                                  │
│  ┌─────────────────────────────────────────────────┐          │
│  │ cmd := exec.Command("bash",                     │  Line 484│
│  │   "./ollama_pull_and_run.sh", modelName)        │          │
│  │ // Command: bash ./ollama_pull_and_run.sh       │          │
│  │ //          qwen2.5-coder:7b                     │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Execute Command                                      │
│  ┌─────────────────────────────────────────────────┐          │
│  │ output, err := cmd.CombinedOutput()             │  Line 487│
│  │ if err != nil {                                  │  Line 488│
│  │   // Script failed, try fallback                │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ├──► SUCCESS PATH                                    │
│           │    Model downloaded successfully                   │
│           │                                                     │
│           └──► FAILURE PATH                                    │
│                ┌───────────────────────────────────┐          │
│                │ cmd = exec.Command("ollama",      │  Line 492│
│                │   "pull", modelName)              │          │
│                │ output, err = cmd.CombinedOutput()│  Line 493│
│                │ // Direct pull without script     │          │
│                └────────┬──────────────────────────┘          │
│                         │                                      │
│                         ▼                                      │
│  Block 3: Add to Available Models                             │
│  ┌─────────────────────────────────────────────────┐          │
│  │ modelExists := false                            │  Line 503│
│  │ for _, model := range AVAILABLE_MODELS {        │  Line 504│
│  │   if model == modelName {                       │  Line 505│
│  │     modelExists = true                          │  Line 506│
│  │   }                                              │          │
│  │ }                                                │          │
│  │ if !modelExists {                                │  Line 510│
│  │   AVAILABLE_MODELS = append(                    │  Line 511│
│  │     AVAILABLE_MODELS, modelName)                │          │
│  │   // Adds "qwen2.5-coder:7b" to global list     │          │
│  │ }                                                │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Return to handleWebSocket
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              CONTINUE MESSAGE PROCESSING                        │
│  Location: main.go - handleWebSocket()                         │
│                                                                 │
│  Block 1: Send Success Notification                            │
│  ┌─────────────────────────────────────────────────┐          │
│  │ successMsg := fmt.Sprintf(                      │  Line 377│
│  │   "Successfully pulled model %s. Ready!",       │          │
│  │   chatMsg.ModelName)                            │          │
│  │ conn.WriteMessage(websocket.TextMessage,        │  Line 378│
│  │                   []byte(successMsg))           │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Update Current Model                                 │
│  ┌─────────────────────────────────────────────────┐          │
│  │ currentModel = chatMsg.ModelName                │  Line 385│
│  │ // Global variable now: "qwen2.5-coder:7b"      │          │
│  │ log.Printf("Switched to model: %s",             │  Line 386│
│  │            currentModel)                        │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 3: Process User Query with LLM                          │
│  ┌─────────────────────────────────────────────────┐          │
│  │ response := processOllamaQueryWithLangChain(    │  Line 392│
│  │   chatMsg.Message, currentModel)                │          │
│  │ // Params: "explain this code",                 │          │
│  │ //         "qwen2.5-coder:7b"                    │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Call LLM Processing
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                LLM QUERY PROCESSING                             │
│  Location: main.go                                              │
│                                                                 │
│  processOllamaQueryWithLangChain() - Lines 563-588             │
│                                                                 │
│  Block 1: Create Context with Timeout                          │
│  ┌─────────────────────────────────────────────────┐          │
│  │ ctx, cancel := context.WithTimeout(             │  Line 565│
│  │   context.Background(), 60*time.Second)         │          │
│  │ defer cancel()                                   │  Line 566│
│  │ // 60 second timeout for LLM response           │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Format Prompt with System Template                   │
│  ┌─────────────────────────────────────────────────┐          │
│  │ formattedPrompt := FormatPrompt(query)          │  Line 569│
│  │ // Uses SystemTemplate (lines 75-82) to wrap    │          │
│  │ // user query with instructions about code      │          │
│  │ // formatting and markdown syntax                │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 3: Initialize Ollama Client via langchaingo             │
│  ┌─────────────────────────────────────────────────┐          │
│  │ llm, err := ollama.New(                         │  Line 572│
│  │   ollama.WithModel(modelName),                  │  Line 573│
│  │ )                                                │          │
│  │ // Creates client for "qwen2.5-coder:7b"        │          │
│  │ // Uses langchaingo library (imported line 18)  │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 4: Call LLM with Prompt                                 │
│  ┌─────────────────────────────────────────────────┐          │
│  │ response, err := llm.Call(ctx,                  │  Line 581│
│  │   formattedPrompt,                              │          │
│  │   llms.WithTemperature(0.7))                    │          │
│  │                                                  │          │
│  │ // langchaingo internally makes HTTP request    │          │
│  │ // to Ollama service (default: localhost:11434) │          │
│  │ // Ollama loads model and generates response    │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 5: Return Response String                               │
│  ┌─────────────────────────────────────────────────┐          │
│  │ return response                                  │  Line 587│
│  │ // Response contains LLM-generated text          │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Return to handleWebSocket
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              SEND RESPONSE TO FRONTEND                          │
│  Location: main.go - handleWebSocket()                         │
│                                                                 │
│  Block 1: Write Response to WebSocket                          │
│  ┌─────────────────────────────────────────────────┐          │
│  │ if err := conn.WriteMessage(                    │  Line 397│
│  │   websocket.TextMessage,                        │          │
│  │   []byte(response)); err != nil {               │          │
│  │   log.Println("WebSocket write error:", err)    │  Line 398│
│  │   return                                         │  Line 399│
│  │ }                                                │          │
│  │ // Sends LLM response back to browser           │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ WebSocket Frame Transmission
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              FRONTEND RECEIVES RESPONSE                         │
│  Location: static/script.js                                     │
│                                                                 │
│  socket.onmessage Event Handler - Lines 32-56                  │
│                                                                 │
│  Block 1: Receive Message                                      │
│  ┌─────────────────────────────────────────────────┐          │
│  │ socket.onmessage = function(event) {            │  Line 32 │
│  │   const message = event.data;                   │  Line 36 │
│  │   // message contains LLM response text         │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Check for Status Messages                            │
│  ┌─────────────────────────────────────────────────┐          │
│  │ if (message.includes('is not installed')) {     │  Line 37 │
│  │   // Handle model pulling notification          │          │
│  │   return;                                        │          │
│  │ }                                                │          │
│  │ // Not a status message, proceed to display     │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 3: Remove Typing Indicator                              │
│  ┌─────────────────────────────────────────────────┐          │
│  │ removeTypingIndicator();                        │  Line 54 │
│  │ // Removes animated "..." indicator              │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 4: Display Message                                      │
│  ┌─────────────────────────────────────────────────┐          │
│  │ addMessage(message, false);                     │  Line 55 │
│  │ // false = bot message (not user)               │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           │ Call addMessage()
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              RENDER MESSAGE IN UI                               │
│  Location: static/script.js                                     │
│                                                                 │
│  addMessage() Function - Lines 147-268                         │
│                                                                 │
│  Block 1: Parse Markdown                                       │
│  ┌─────────────────────────────────────────────────┐          │
│  │ contentDiv.innerHTML = marked.parse(content);   │  Line 169│
│  │ // Uses marked.js library to convert markdown   │          │
│  │ // to HTML with code blocks, headers, etc.      │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 2: Apply Syntax Highlighting                            │
│  ┌─────────────────────────────────────────────────┐          │
│  │ contentDiv.querySelectorAll('pre code')         │  Line 172│
│  │   .forEach((block) => {                         │          │
│  │     hljs.highlightElement(block);               │  Line 173│
│  │     // Uses highlight.js to colorize code       │          │
│  │   });                                            │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 3: Add Copy Buttons                                     │
│  ┌─────────────────────────────────────────────────┐          │
│  │ const copyCodeButton =                          │  Line 189│
│  │   document.createElement('button');             │          │
│  │ copyCodeButton.className = 'copy-button';       │  Line 190│
│  │ copyCodeButton.textContent = 'Copy';            │  Line 191│
│  │ // Adds "Copy" button to each code block        │          │
│  └────────┬────────────────────────────────────────┘          │
│           │                                                     │
│           ▼                                                     │
│  Block 4: Append to Chat Messages                              │
│  ┌─────────────────────────────────────────────────┐          │
│  │ chatMessages.appendChild(messageRow);           │  Line 264│
│  │ // Adds message to DOM                          │          │
│  │ chatMessages.scrollTop =                        │  Line 267│
│  │   chatMessages.scrollHeight;                    │          │
│  │ // Auto-scroll to bottom                        │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌───────────────┐
                    │  USER SEES    │
                    │  AI RESPONSE  │
                    └───────────────┘
```

---

## User Model Selection Flow

### Step-by-Step Execution When User Selects a Model

#### Step 1: User Interaction (HTML)
```html
<!-- index.html, Lines 96-113 -->
<select id="model-select" class="model-dropdown" title="Select Model">
    <option value="llama3.1:8b" selected>Llama 3.1 ✓</option>
    <option value="qwen2.5-coder:7b">Qwen3 Coder (Not Installed)</option>
    ...
</select>
```
**What happens**: User clicks dropdown and selects "qwen2.5-coder:7b"

---

#### Step 2: Event Listener Triggers (JavaScript)
```javascript
// script.js, Line 454
modelSelect.addEventListener('change', function() {
    const selectedModel = this.value;  // Line 455: "qwen2.5-coder:7b"
    console.log(`Model changed to: ${selectedModel}`);  // Line 456
    
    // Line 459: Get the selected option element
    const selectedOption = this.options[this.selectedIndex];
    
    // Line 460: Check if model is not installed
    if (selectedOption.text.includes('(Not Installed)')) {
        // Lines 462-471: Show warning notification
        const notification = document.createElement('div');
        notification.className = 'model-change-notification';
        notification.textContent = `Model ${selectedOption.text} will be downloaded when you send a message`;
        notification.style.backgroundColor = '#f59e0b';
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.opacity = '0';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
});
```

**Execution Flow**:
1. JavaScript detects `change` event on `<select>` element
2. Extracts selected model name: `"qwen2.5-coder:7b"`
3. Checks option text for `"(Not Installed)"` marker
4. If not installed: Creates orange notification banner
5. Notification auto-fades after 3 seconds
6. Model selection is stored but NOT downloaded yet

---

#### Step 3: User Sends Message (JavaScript)
```javascript
// script.js, Line 336
async function sendMessage(message) {
    try {
        showTypingIndicator();  // Line 338: Show "..." animation
        
        // Line 341: Get the currently selected model
        const selectedModel = modelSelect.value;  // "qwen2.5-coder:7b"
        console.log(`Sending message with model: ${selectedModel}`);
        
        // Line 345: Check WebSocket connection status
        if (isConnected && socket.readyState === WebSocket.OPEN) {
            // Line 347-350: Send via WebSocket
            socket.send(JSON.stringify({
                message: message,
                model_name: selectedModel
            }));
        }
    }
}
```

**Execution Flow**:
1. Function receives user's typed message
2. Retrieves selected model from dropdown (`modelSelect.value`)
3. Checks if WebSocket is connected
4. Packages data as JSON: `{message: "...", model_name: "qwen2.5-coder:7b"}`
5. Sends JSON string through WebSocket connection

---

#### Step 4: Backend Receives Request (Go)
```go
// main.go, Line 308
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
    // Line 310: Upgrade HTTP to WebSocket
    conn, err := upgrader.Upgrade(w, r, nil)
    
    for {
        // Line 325: Read message from WebSocket
        messageType, p, err := conn.ReadMessage()
        // p = []byte(`{"message":"explain","model_name":"qwen2.5-coder:7b"}`)
        
        // Line 334-335: Parse JSON into Go struct
        var chatMsg ChatMessage
        if err := json.Unmarshal(p, &chatMsg); err != nil {
            log.Printf("Error parsing message: %v", err)
            continue
        }
        // Now: chatMsg.Message = "explain"
        //      chatMsg.ModelName = "qwen2.5-coder:7b"
        
        // Line 352: Check if new model requested
        if chatMsg.ModelName != "" && chatMsg.ModelName != currentModel {
            // Line 354: Check if model is installed locally
            if !checkModelInstalled(chatMsg.ModelName) {
                // MODEL NOT INSTALLED - Continue to pull...
            }
        }
    }
}
```

**Execution Flow**:
1. Go receives WebSocket message as byte array
2. Unmarshals JSON into `ChatMessage` struct
3. Extracts `ModelName` field: `"qwen2.5-coder:7b"`
4. Compares with `currentModel` global variable
5. If different, calls `checkModelInstalled()` function

---

#### Step 5: Check Model Installation (Go)
```go
// main.go, Line 451
func checkModelInstalled(modelName string) bool {
    // Line 452: Execute shell command
    cmd := exec.Command("ollama", "list")
    output, err := cmd.CombinedOutput()
    // Output example:
    // NAME                    ID       SIZE     MODIFIED
    // llama3.1:8b            abc123   4.7GB    2 days ago
    // mistral:7b             def456   4.1GB    1 week ago
    
    // Line 459: Split output into lines
    lines := strings.Split(string(output), "\n")
    for i, line := range lines {
        if i == 0 || len(line) == 0 {
            continue  // Skip header and empty lines
        }
        
        // Line 465: Parse each line
        fields := strings.Fields(line)
        if len(fields) >= 1 {
            installedModel := fields[0]  // "llama3.1:8b", "mistral:7b"
            
            // Line 470: Check if matches requested model
            if installedModel == modelName || 
               strings.HasPrefix(installedModel, modelName+":") {
                return true  // FOUND!
            }
        }
    }
    return false  // NOT FOUND
}
```

**Execution Flow**:
1. Runs shell command: `ollama list`
2. Receives output showing installed models
3. Parses output line by line
4. Compares each installed model name with requested model
5. Returns `true` if found, `false` if not found
6. In our case: `"qwen2.5-coder:7b"` NOT in list → returns `false`

---

#### Step 6: Auto-Pull Model (Go)
```go
// main.go, Line 356 (inside handleWebSocket)
if !checkModelInstalled(chatMsg.ModelName) {
    log.Printf("Model %s not installed, attempting to pull...", chatMsg.ModelName)
    
    // Line 359-363: Send status message to user
    statusMsg := fmt.Sprintf("Model %s is not installed. Pulling it now, this may take a few minutes...", chatMsg.ModelName)
    if err := conn.WriteMessage(websocket.TextMessage, []byte(statusMsg)); err != nil {
        log.Println("WebSocket write error:", err)
        return
    }
    
    // Line 366: Pull the model
    _, pullErr := pullOllamaModel(chatMsg.ModelName)
}

// Line 479: pullOllamaModel function
func pullOllamaModel(modelName string) (string, error) {
    log.Printf("Attempting to pull model: %s", modelName)
    
    // Line 484: Try script first
    cmd := exec.Command("bash", "./ollama_pull_and_run.sh", modelName)
    output, err := cmd.CombinedOutput()
    
    if err != nil {
        // Line 492-493: Fallback to direct pull
        log.Printf("Falling back to direct ollama pull...")
        cmd = exec.Command("ollama", "pull", modelName)
        output, err = cmd.CombinedOutput()
        
        if err != nil {
            return "", fmt.Errorf("failed to pull model %s: %v", modelName, err)
        }
    }
    
    // Line 503-512: Add to available models list
    modelExists := false
    for _, model := range AVAILABLE_MODELS {
        if model == modelName {
            modelExists = true
            break
        }
    }
    if !modelExists {
        AVAILABLE_MODELS = append(AVAILABLE_MODELS, modelName)
    }
    
    return string(output), nil
}
```

**Execution Flow**:
1. Send notification to frontend: "Pulling model..."
2. Execute shell script: `bash ./ollama_pull_and_run.sh qwen2.5-coder:7b`
3. If script fails, fallback to: `ollama pull qwen2.5-coder:7b`
4. Ollama service downloads model (multi-GB download)
5. After success, add model to `AVAILABLE_MODELS` array
6. Return control to `handleWebSocket`

---

#### Step 7: Update Current Model and Process Query (Go)
```go
// main.go, Line 377-386 (inside handleWebSocket)
// Send success message
successMsg := fmt.Sprintf("Successfully pulled model %s. Ready to use!", chatMsg.ModelName)
if err := conn.WriteMessage(websocket.TextMessage, []byte(successMsg)); err != nil {
    log.Println("WebSocket write error:", err)
    return
}

// Update the current model
currentModel = chatMsg.ModelName  // Now: "qwen2.5-coder:7b"
log.Printf("Switched to model: %s", currentModel)

// Line 392: Process the message with Ollama
response := processOllamaQueryWithLangChain(chatMsg.Message, currentModel)
```

**Execution Flow**:
1. Send success notification to frontend
2. Update global variable: `currentModel = "qwen2.5-coder:7b"`
3. Call `processOllamaQueryWithLangChain()` with new model
4. Continue to LLM processing...

---

## Message Processing Flow

### Complete Code Path for LLM Query

#### Block 1: Initialize LLM Client
```go
// main.go, Lines 563-588
func processOllamaQueryWithLangChain(query string, modelName string) string {
    // Line 565: Create context with 60-second timeout
    ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
    defer cancel()
    
    // Line 569: Format prompt with system template
    formattedPrompt := FormatPrompt(query)
    // Uses template from lines 75-82 to add instructions about
    // code formatting and markdown syntax
    
    // Line 572-574: Initialize Ollama client
    llm, err := ollama.New(
        ollama.WithModel(modelName),  // "qwen2.5-coder:7b"
    )
    if err != nil {
        log.Printf("Error initializing Ollama: %v", err)
        return fmt.Sprintf("Error initializing Ollama: %v", err)
    }
    
    // Line 581: Call LLM with formatted prompt
    response, err := llm.Call(ctx, formattedPrompt, llms.WithTemperature(0.7))
    if err != nil {
        log.Printf("Error calling Ollama: %v", err)
        return fmt.Sprintf("Error generating response: %v", err)
    }
    
    return response  // Return generated text
}
```

**What Happens Under the Hood**:
1. **Context Creation**: Sets 60-second deadline for request
2. **Prompt Formatting**: Wraps user query with system instructions
3. **Client Init**: `langchaingo` library creates Ollama client
4. **HTTP Request**: Library makes POST to `http://localhost:11434/api/generate`
5. **Ollama Service**: 
   - Loads model weights into memory
   - Runs transformer inference
   - Generates tokens sequentially
   - Returns complete response
6. **Response**: String containing AI-generated text

---

#### Block 2: Frontend Receives and Renders
```javascript
// script.js, Lines 32-56
socket.onmessage = function(event) {
    const message = event.data;  // LLM response text
    
    // Line 37-52: Check for status messages
    if (message.includes('is not installed. Pulling it now')) {
        isPullingModel = true;
        showModelPullingIndicator(message);
        return;
    }
    
    // Line 54: Remove typing indicator
    removeTypingIndicator();
    
    // Line 55: Display message
    addMessage(message, false);  // false = bot message
};

// Lines 147-268: addMessage function
function addMessage(content, isUser = false) {
    // Line 149: Hide center UI on first message
    hideCenterContent();
    
    // Create message elements...
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content markdown-body';
    
    // Line 169: Parse markdown to HTML
    contentDiv.innerHTML = marked.parse(content);
    // Converts: "```python\nprint('hello')\n```"
    // To: "<pre><code class=\"language-python\">print('hello')</code></pre>"
    
    // Line 172-174: Apply syntax highlighting
    contentDiv.querySelectorAll('pre code').forEach((block) => {
        hljs.highlightElement(block);
        // highlight.js adds color classes to code tokens
    });
    
    // Lines 189-223: Add copy buttons to code blocks
    // ... (copy button creation code)
    
    // Line 264: Add to DOM
    chatMessages.appendChild(messageRow);
    
    // Line 267: Auto-scroll to bottom
    chatMessages.scrollTop = chatMessages.scrollHeight;
}
```

**Rendering Pipeline**:
1. Receive raw markdown text from WebSocket
2. Parse markdown → HTML using `marked.js`
3. Apply syntax highlighting using `highlight.js`
4. Add copy buttons to code blocks
5. Insert into DOM
6. Scroll chat window to show new message

---

## Critical Integration Points

### 1. JavaScript → Go Communication

**JavaScript Side (script.js:347-350)**:
```javascript
socket.send(JSON.stringify({
    message: message,
    model_name: selectedModel
}));
```

**Go Side (main.go:334-349)**:
```go
var chatMsg ChatMessage
if err := json.Unmarshal(p, &chatMsg); err != nil {
    // Handle error
}
// Now: chatMsg.Message and chatMsg.ModelName are populated
```

**Data Structure Mapping**:
```
JavaScript Object          Go Struct (main.go:29-32)
═════════════════          ═════════════════════════
{                          type ChatMessage struct {
  message: string    →         Message   string `json:"message"`
  model_name: string →         ModelName string `json:"model_name,omitempty"`
}                          }
```

---

### 2. Go → Shell Integration

**Go Code (main.go:452, 484, 492)**:
```go
// Check installed models
cmd := exec.Command("ollama", "list")

// Pull model (script)
cmd := exec.Command("bash", "./ollama_pull_and_run.sh", modelName)

// Pull model (direct)
cmd := exec.Command("ollama", "pull", modelName)
```

**Shell Commands Executed**:
```bash
# 1. List installed models
$ ollama list
NAME                ID       SIZE     MODIFIED
llama3.1:8b        abc123   4.7GB    2 days ago

# 2. Pull new model (via script with optimizations)
$ bash ./ollama_pull_and_run.sh qwen2.5-coder:7b

# 3. Pull new model (direct fallback)
$ ollama pull qwen2.5-coder:7b
```

---

### 3. Go → Ollama Service via langchaingo

**Go Code (main.go:572-585)**:
```go
llm, err := ollama.New(
    ollama.WithModel(modelName),
)
response, err := llm.Call(ctx, formattedPrompt, llms.WithTemperature(0.7))
```

**What langchaingo Does**:
```
1. Constructs HTTP POST request to http://localhost:11434/api/generate
2. Payload:
   {
     "model": "qwen2.5-coder:7b",
     "prompt": "You are a helpful coding assistant...\nUser Query: explain this code",
     "temperature": 0.7
   }
3. Ollama service receives request
4. Loads model into GPU/CPU memory
5. Runs inference
6. Returns JSON: {"response": "This code..."}
7. langchaingo extracts response text and returns as string
```

---

### 4. State Synchronization

**Global State Variables**:

**Go (main.go)**:
```go
var currentModel = "llama3.1:8b"  // Line 73
var AVAILABLE_MODELS = []string{...}  // Lines 47-67
```

**JavaScript (script.js)**:
```javascript
let socket;  // WebSocket connection
let isConnected = false;  // Connection state
let isPullingModel = false;  // Model download state
const modelSelect = document.getElementById('model-select');  // Selected model
```

**State Updates**:
1. User selects model → `modelSelect.value` updated
2. Message sent → Go receives `chatMsg.ModelName`
3. Model validated → Go updates `currentModel`
4. Model pulled → Go updates `AVAILABLE_MODELS`
5. Status returned → JS updates `isPullingModel`
6. Response received → JS updates UI

---

## Summary Table

| Component | File | Lines | Purpose |
|-----------|------|-------|---------|
| **Model Dropdown** | index.html | 96-113 | HTML select element |
| **Selection Handler** | script.js | 454-484 | Event listener for model change |
| **Message Sender** | script.js | 336-381 | Packages and sends user input |
| **WebSocket Receiver** | main.go | 308-404 | Receives messages from frontend |
| **Model Checker** | main.go | 451-476 | Verifies model installation |
| **Model Puller** | main.go | 479-515 | Downloads missing models |
| **LLM Processor** | main.go | 563-588 | Generates AI responses |
| **Response Renderer** | script.js | 147-268 | Displays formatted messages |

---

## Key Takeaways

1. **Model selection is stored locally** in JavaScript but only validated/loaded when user sends a message
2. **Auto-pull feature** triggers when backend detects missing model via `ollama list` command
3. **Communication uses JSON** with matching structures on both sides (`ChatMessage` in Go, plain object in JS)
4. **langchaingo library** abstracts Ollama HTTP API calls, making Go code cleaner
5. **Markdown rendering pipeline** (marked.js → highlight.js → DOM) provides rich code formatting
6. **WebSocket connection** with auto-reconnect ensures reliable real-time communication
7. **Error handling** includes multiple fallback paths (script failure → direct pull, WebSocket down → HTTP fallback)
