# OllamaMax - Mermaid Flow Diagrams

## 1. Complete User Interaction Flow

```mermaid
graph TB
    Start([User Opens Browser]) --> LoadPage[Load index.html]
    LoadPage --> LoadAssets[Load CSS, JS, Libraries]
    LoadAssets --> DOMReady[DOMContentLoaded Event]
    
    DOMReady --> InitVars[Initialize Variables<br/>script.js:2-18]
    InitVars --> ConnectWS[Connect WebSocket<br/>script.js:24-72]
    InitVars --> CheckStatus[Check Model Status<br/>GET /api/models/status<br/>script.js:75-105]
    
    ConnectWS --> WSOpen{WebSocket<br/>Connected?}
    WSOpen -->|Yes| SetConnected[isConnected = true]
    WSOpen -->|No| Retry[Retry after 3s<br/>script.js:62]
    Retry --> ConnectWS
    
    CheckStatus --> UpdateUI[Update Model Dropdown<br/>Mark Installed Models ✓<br/>script.js:83-97]
    
    SetConnected --> AttachEvents[Attach Event Listeners<br/>script.js:384-587]
    UpdateUI --> AttachEvents
    
    AttachEvents --> Ready[Display Center UI<br/>Ready for Input]
    
    Ready --> UserAction{User Action}
    
    UserAction -->|Select Model| ModelChange[Model Change Event<br/>script.js:454-484]
    UserAction -->|Type Message| TypeMsg[User Types in Input]
    UserAction -->|Click Send| SendClick[Send Button Click<br/>script.js:384-396]
    UserAction -->|Press Enter| EnterKey[Enter Key Press<br/>script.js:399-404]
    
    ModelChange --> CheckInstalled{Model<br/>Installed?}
    CheckInstalled -->|Yes| NotifyReady[Show 'Switched to Model'<br/>script.js:474-482]
    CheckInstalled -->|No| NotifyPull[Show 'Will download'<br/>script.js:462-471]
    
    TypeMsg --> UserAction
    NotifyReady --> Ready
    NotifyPull --> Ready
    
    SendClick --> ValidateInput{Input<br/>Not Empty?}
    EnterKey --> ValidateInput
    
    ValidateInput -->|No| Ready
    ValidateInput -->|Yes| AddUserMsg[Add Message to UI<br/>script.js:147-268]
    
    AddUserMsg --> HideCenter[Hide Center Content<br/>Show Bottom Input<br/>script.js:133-144]
    HideCenter --> SendToBackend[sendMessage Function<br/>script.js:336-381]
    
    SendToBackend --> ShowTyping[Show Typing Indicator<br/>script.js:271-283]
    ShowTyping --> SelectModel[Get Selected Model<br/>modelSelect.value<br/>script.js:341]
    
    SelectModel --> CheckConnection{WebSocket<br/>Connected?}
    
    CheckConnection -->|Yes| SendWS[Send via WebSocket<br/>JSON: message, model_name<br/>script.js:347-350]
    CheckConnection -->|No| SendHTTP[Send via HTTP POST<br/>/api/chat<br/>script.js:353-375]
    
    SendWS --> BackendWS[Go WebSocket Handler<br/>handleWebSocket<br/>main.go:308-404]
    SendHTTP --> BackendHTTP[Go HTTP Handler<br/>handleChat<br/>main.go:247-305]
    
    BackendWS --> ParseJSON[Unmarshal JSON<br/>main.go:335-349]
    BackendHTTP --> ParseJSON
    
    ParseJSON --> CheckModel{Model Name<br/>Provided?}
    
    CheckModel -->|Yes| CheckInstall[checkModelInstalled<br/>main.go:451-476<br/>Run: ollama list]
    CheckModel -->|No| UseCurrentModel[Use currentModel<br/>main.go:73]
    
    CheckInstall --> IsInstalled{Model<br/>Installed?}
    
    IsInstalled -->|Yes| UpdateCurrent[Update currentModel<br/>main.go:385-386]
    IsInstalled -->|No| NotifyPulling[Send 'Pulling model'<br/>main.go:359-363]
    
    NotifyPulling --> ShowPullUI[Show Model Pulling Indicator<br/>script.js:294-319]
    ShowPullUI --> PullModel[pullOllamaModel<br/>main.go:479-515]
    
    PullModel --> RunScript[Run Shell Script<br/>./ollama_pull_and_run.sh<br/>main.go:484]
    RunScript --> ScriptFail{Success?}
    
    ScriptFail -->|No| Fallback[Fallback: ollama pull<br/>main.go:492-497]
    ScriptFail -->|Yes| AddToList[Add to AVAILABLE_MODELS<br/>main.go:503-512]
    Fallback --> AddToList
    
    AddToList --> SendSuccess[Send 'Successfully pulled'<br/>main.go:377-381]
    SendSuccess --> HidePullUI[Hide Pulling Indicator<br/>script.js:322-333]
    HidePullUI --> UpdateCurrent
    
    UseCurrentModel --> ProcessQuery[processOllamaQueryWithLangChain<br/>main.go:392, 563-588]
    UpdateCurrent --> ProcessQuery
    
    ProcessQuery --> FormatPrompt[Format Prompt with Template<br/>main.go:569]
    FormatPrompt --> InitOllama[Initialize Ollama Client<br/>langchaingo<br/>main.go:572-578]
    
    InitOllama --> CallLLM[Call LLM<br/>llm.Call with model & prompt<br/>main.go:581-585]
    
    CallLLM --> OllamaService[Ollama Service<br/>Model Inference]
    OllamaService --> GetResponse[Get Response String<br/>main.go:587]
    
    GetResponse --> SendResponse{Which<br/>Protocol?}
    
    SendResponse -->|WebSocket| SendWSResp[Send via WebSocket<br/>main.go:397-400]
    SendResponse -->|HTTP| SendHTTPResp[Send JSON Response<br/>main.go:299-304]
    
    SendWSResp --> ReceiveJS[Receive in JavaScript<br/>socket.onmessage<br/>script.js:32-56]
    SendHTTPResp --> ReceiveJS
    
    ReceiveJS --> RemoveTyping[Remove Typing Indicator<br/>script.js:54, 286-291]
    RemoveTyping --> ParseMarkdown[Parse Markdown<br/>marked.parse<br/>script.js:169]
    
    ParseMarkdown --> Highlight[Apply Syntax Highlighting<br/>hljs.highlightElement<br/>script.js:172-224]
    
    Highlight --> DisplayMsg[Display Message in UI<br/>script.js:264-267]
    DisplayMsg --> ScrollChat[Scroll to Bottom<br/>script.js:267]
    
    ScrollChat --> Ready
    
    style Start fill:#e1f5e1
    style Ready fill:#fff4e1
    style BackendWS fill:#e1e8f5
    style BackendHTTP fill:#e1e8f5
    style OllamaService fill:#f5e1f5
    style DisplayMsg fill:#e1f5e1
```

## 2. Model Selection & Auto-Pull Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as Browser UI
    participant JS as script.js
    participant Go as main.go
    participant Shell as Shell Scripts
    participant Ollama as Ollama Service

    User->>UI: Select Model from Dropdown
    UI->>JS: Change Event (line 454)
    JS->>JS: Check if "(Not Installed)" in text (line 460)
    
    alt Model Not Installed
        JS->>UI: Show Warning Notification (line 462-471)
        UI-->>User: "Will be downloaded when you send message"
    else Model Installed
        JS->>UI: Show Success Notification (line 474-482)
        UI-->>User: "Switched to model"
    end
    
    User->>UI: Type Message & Click Send
    UI->>JS: sendMessage() called (line 336)
    JS->>JS: Get modelSelect.value (line 341)
    
    alt WebSocket Connected
        JS->>Go: Send JSON via WebSocket (line 347-350)
        Note over JS,Go: {message, model_name}
    else WebSocket Disconnected
        JS->>Go: POST /api/chat (line 353-361)
    end
    
    Go->>Go: handleWebSocket/handleChat (line 308/247)
    Go->>Go: Unmarshal JSON (line 335)
    Go->>Go: Check if model_name provided (line 352)
    
    Go->>Go: checkModelInstalled() (line 451)
    Go->>Shell: Execute "ollama list" (line 452)
    Shell-->>Go: Return installed models list
    Go->>Go: Parse output, check if model exists (line 459-475)
    
    alt Model Not Found
        Go->>JS: Send "Pulling model..." message (line 359)
        JS->>UI: Show Pulling Indicator (line 294-319)
        UI->>UI: Disable inputs, show spinner
        
        Go->>Go: pullOllamaModel() (line 479)
        Go->>Shell: Run ./ollama_pull_and_run.sh model_name (line 484)
        Shell->>Ollama: Pull model with optimizations
        
        alt Script Success
            Ollama-->>Shell: Model downloaded
            Shell-->>Go: Success output
        else Script Failed
            Go->>Shell: Fallback: ollama pull (line 492)
            Shell->>Ollama: Direct pull
            Ollama-->>Shell: Model downloaded
            Shell-->>Go: Success output
        end
        
        Go->>Go: Add to AVAILABLE_MODELS (line 503-512)
        Go->>JS: Send "Successfully pulled" (line 377)
        JS->>UI: Hide Pulling Indicator (line 322)
        UI->>UI: Re-enable inputs
        JS->>Go: GET /api/models/status (line 44)
        Go-->>JS: Updated model status
        JS->>UI: Update dropdown with ✓ (line 86-91)
    end
    
    Go->>Go: Update currentModel = model_name (line 385)
    Go->>Go: processOllamaQueryWithLangChain() (line 392)
    Go->>Go: Format prompt with template (line 569)
    Go->>Ollama: Initialize client & call LLM (line 572-585)
    Note over Go,Ollama: langchaingo library
    Ollama->>Ollama: Run inference with model
    Ollama-->>Go: Return response text (line 581)
    
    Go->>JS: Send response via WebSocket/HTTP (line 397)
    JS->>JS: socket.onmessage / fetch response (line 32)
    JS->>JS: Remove typing indicator (line 54, 286)
    JS->>JS: Parse markdown with marked.js (line 169)
    JS->>JS: Apply syntax highlighting (line 172-174)
    JS->>UI: Display formatted message (line 264)
    UI-->>User: Show AI response
```

## 3. WebSocket Lifecycle & Reconnection

```mermaid
stateDiagram-v2
    [*] --> Disconnected: Page Load
    
    Disconnected --> Connecting: connectWebSocket() called<br/>script.js:24
    
    Connecting --> Connected: socket.onopen<br/>script.js:27-30
    Connecting --> Error: socket.onerror<br/>script.js:65-68
    
    Connected --> MessageSent: User sends message<br/>script.js:347
    Connected --> Disconnected: socket.onclose<br/>script.js:58-63
    Connected --> Error: socket.onerror
    
    MessageSent --> AwaitingResponse: Waiting for server
    AwaitingResponse --> MessageReceived: socket.onmessage<br/>script.js:32-56
    MessageReceived --> Connected: Message processed
    
    Error --> Disconnected: Connection failed
    Disconnected --> Reconnecting: After 3s delay<br/>script.js:62
    Reconnecting --> Connecting: Retry connection
    
    Connected --> HTTPFallback: Connection check fails<br/>script.js:345-375
    HTTPFallback --> Connected: WebSocket restored
    
    note right of Connected
        isConnected = true
        socket.readyState === WebSocket.OPEN
    end note
    
    note right of Disconnected
        isConnected = false
        Auto-retry enabled
    end note
```

## 4. Backend API Architecture

```mermaid
graph LR
    Client[Browser Client]
    
    subgraph "Go Server :8888"
        Router[Gorilla Mux Router<br/>main.go:129]
        
        Router --> GET1[GET /<br/>Serve index.html<br/>line 132-134]
        Router --> GET2[GET /api<br/>API Status<br/>line 137-144]
        Router --> GET3[GET /api/models<br/>Available Models<br/>line 147]
        Router --> GET4[GET /api/models/installed-models<br/>Installed Models<br/>line 150]
        Router --> GET5[GET /api/models/status<br/>Model Status<br/>line 189]
        Router --> GET6[GET /api/health<br/>Health Check<br/>line 159-183]
        Router --> GET7[GET /api/chat/ws<br/>WebSocket<br/>line 156]
        Router --> POST1[POST /api/chat<br/>HTTP Chat<br/>line 153]
        Router --> POST2[POST /api/models/pull<br/>Pull Model<br/>line 186]
        Router --> Static[Static Files<br/>line 192-193]
        
        GET3 --> HandlerA[getAvailableModels<br/>line 201-212]
        GET4 --> HandlerB[getModels<br/>line 407-448]
        GET5 --> HandlerC[getModelStatus<br/>line 215-244]
        GET7 --> HandlerD[handleWebSocket<br/>line 308-404]
        POST1 --> HandlerE[handleChat<br/>line 247-305]
        POST2 --> HandlerF[handleModelPull<br/>line 518-560]
        
        HandlerD --> Process1[processOllamaQueryWithLangChain<br/>line 563-588]
        HandlerE --> Process1
        
        HandlerC --> Check1[checkModelInstalled<br/>line 451-476]
        HandlerD --> Check1
        HandlerE --> Check1
        
        HandlerD --> Pull1[pullOllamaModel<br/>line 479-515]
        HandlerE --> Pull1
        HandlerF --> Pull1
        
        HandlerB --> Shell1[exec.Command<br/>ollama list]
        Check1 --> Shell1
        Pull1 --> Shell2[exec.Command<br/>ollama pull / script]
        
        Process1 --> LangChain[langchaingo Library<br/>ollama.New<br/>llm.Call<br/>line 572-585]
    end
    
    subgraph "External Services"
        Shell1 --> Ollama1[Ollama CLI]
        Shell2 --> Ollama1
        LangChain --> Ollama2[Ollama Service<br/>HTTP API]
    end
    
    Client -->|HTTP/WS Requests| Router
    Router -->|Responses| Client
    
    style Router fill:#e1e8f5
    style Process1 fill:#f5e1e1
    style LangChain fill:#f5e1f5
    style Ollama2 fill:#f5e1f5
```

## 5. Data Structures & Message Flow

```mermaid
graph TD
    subgraph "Frontend JavaScript"
        JSMsg[JavaScript Message Object<br/>script.js:347-350]
        JSMsg --> JSONStr["JSON.stringify<br/>{<br/>  message: string,<br/>  model_name: string<br/>}"]
    end
    
    subgraph "Network Layer"
        JSONStr -->|WebSocket| WSTransport[WebSocket Frame]
        JSONStr -->|HTTP| HTTPTransport[HTTP POST Body]
    end
    
    subgraph "Backend Go Structures"
        WSTransport --> GoUnmarshal[json.Unmarshal<br/>main.go:335]
        HTTPTransport --> GoUnmarshal
        
        GoUnmarshal --> ChatMsgStruct["ChatMessage struct<br/>main.go:29-32<br/>{<br/>  Message string<br/>  ModelName string<br/>}"]
        
        ChatMsgStruct --> Processing[Process Message]
        
        Processing --> ResponseStruct["ChatResponse struct<br/>main.go:41-44<br/>{<br/>  Response string<br/>  Action string<br/>}"]
        
        ResponseStruct --> GoMarshal[json.Marshal<br/>main.go:299, 552]
    end
    
    subgraph "Response Path"
        GoMarshal -->|WebSocket| WSResponse[conn.WriteMessage<br/>main.go:397]
        GoMarshal -->|HTTP| HTTPResponse[json.Encode<br/>main.go:299]
        
        WSResponse --> JSReceive1[socket.onmessage<br/>script.js:32]
        HTTPResponse --> JSReceive2[fetch response.json<br/>script.js:370]
        
        JSReceive1 --> JSParse[Parse Response]
        JSReceive2 --> JSParse
        
        JSParse --> MarkdownParse[marked.parse<br/>script.js:169]
        MarkdownParse --> HTMLRender[Render to DOM<br/>script.js:264]
    end
    
    subgraph "State Management"
        GlobalState["Global Variables<br/>━━━━━━━━━━━━━━<br/>Go:<br/>  currentModel string<br/>  AVAILABLE_MODELS []string<br/>━━━━━━━━━━━━━━<br/>JavaScript:<br/>  socket WebSocket<br/>  isConnected bool<br/>  isPullingModel bool"]
    end
    
    Processing -.Updates.-> GlobalState
    JSMsg -.Reads.-> GlobalState
    
    style JSMsg fill:#e1f5e1
    style ChatMsgStruct fill:#e1e8f5
    style ResponseStruct fill:#e1e8f5
    style MarkdownParse fill:#f5e1e1
    style GlobalState fill:#fff4e1
```

## 6. Error Handling Flowchart

```mermaid
graph TB
    Start([Application Running])
    
    Start --> UserAction[User Sends Message]
    
    UserAction --> TrySend{Try Send}
    
    TrySend -->|Error| ErrorType{Error Type?}
    TrySend -->|Success| Backend[Backend Receives]
    
    ErrorType -->|Network Error| NetError[Network Error<br/>script.js:377-379]
    ErrorType -->|WebSocket Closed| WSError[WebSocket Error<br/>script.js:65-68]
    ErrorType -->|HTTP Error| HTTPError[HTTP Error<br/>script.js:364-367]
    
    NetError --> ShowError[Show Error Message<br/>script.js:379]
    WSError --> Reconnect[Auto Reconnect<br/>script.js:62]
    HTTPError --> ShowError
    
    Reconnect --> TrySend
    ShowError --> Ready[Ready for Next Input]
    
    Backend --> BackendProc{Backend Processing}
    
    BackendProc -->|Model Not Installed| AutoPull[Auto-Pull Model<br/>main.go:266-286]
    BackendProc -->|Ollama Down| OllamaError[Return 503 Error<br/>main.go:162-172]
    BackendProc -->|Success| ProcessLLM[Process with LLM]
    
    AutoPull --> PullResult{Pull Success?}
    
    PullResult -->|Success| ProcessLLM
    PullResult -->|Failed Script| Fallback[Try Direct Pull<br/>main.go:492-497]
    
    Fallback --> FallbackResult{Success?}
    FallbackResult -->|Yes| ProcessLLM
    FallbackResult -->|No| PullError[Return Pull Error<br/>main.go:280-285]
    
    OllamaError --> DisplayError[Display Error in UI]
    PullError --> DisplayError
    
    ProcessLLM --> LLMResult{LLM Call}
    
    LLMResult -->|Error| LLMError[Log & Return Error<br/>main.go:576-577, 582-584]
    LLMResult -->|Success| SendResponse[Send Response]
    
    LLMError --> DisplayError
    
    SendResponse --> DisplayMsg[Display in UI]
    DisplayError --> Ready
    DisplayMsg --> Ready
    
    style ErrorType fill:#ffcccc
    style NetError fill:#ffcccc
    style WSError fill:#ffcccc
    style HTTPError fill:#ffcccc
    style OllamaError fill:#ffcccc
    style PullError fill:#ffcccc
    style LLMError fill:#ffcccc
    style Ready fill:#ccffcc
```

## 7. Component Interaction Timeline

```mermaid
gantt
    title OllamaMax - Complete Request Timeline
    dateFormat X
    axisFormat %L ms
    
    section Browser
    Page Load                      :0, 100
    Initialize JS                  :100, 50
    Connect WebSocket             :150, 100
    User Types Message            :250, 500
    Click Send                    :750, 10
    Package & Send                :760, 40
    Show Typing Indicator         :800, 1500
    Receive Response              :2300, 50
    Parse Markdown                :2350, 100
    Apply Highlighting            :2450, 150
    Display Message               :2600, 50
    
    section Go Server
    Receive Request               :800, 50
    Unmarshal JSON                :850, 20
    Check Model Status            :870, 100
    Process Query                 :970, 1200
    Format Response               :2170, 30
    Send Response                 :2200, 100
    
    section Ollama
    Receive LLM Call              :970, 50
    Load Model                    :1020, 150
    Run Inference                 :1170, 1000
    Return Result                 :2170, 50
    
    section Shell
    Execute ollama list           :870, 100
```

## Key File & Line References

### JavaScript (script.js)
- **Lines 1-23**: Variable declarations and setup
- **Lines 24-72**: WebSocket connection management  
- **Lines 75-105**: Model status checking
- **Lines 147-268**: Message display and UI rendering
- **Lines 271-333**: Loading indicators (typing, pulling)
- **Lines 336-381**: Message sending logic
- **Lines 384-446**: Event listeners (send, enter, model change)
- **Lines 454-484**: Model selection handler

### Go (main.go)
- **Lines 47-73**: Global variables (models, state)
- **Lines 127-198**: Router setup and endpoints
- **Lines 201-244**: Model info endpoints
- **Lines 247-305**: HTTP chat handler
- **Lines 308-404**: WebSocket chat handler
- **Lines 407-448**: Get installed models
- **Lines 451-476**: Check model installed
- **Lines 479-515**: Pull/download model
- **Lines 518-560**: Model pull endpoint
- **Lines 563-588**: LLM query processing

### HTML (index.html)
- **Lines 96-113**: Model selector dropdown
- **Lines 118-120**: Chat messages container
- **Lines 123-132**: Bottom input area (post-message)
- **Lines 135-194**: Center content area (initial)
