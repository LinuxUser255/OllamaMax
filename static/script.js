document.addEventListener('DOMContentLoaded', function() {
    const chatMessages = document.getElementById('chat-messages');
    const userInput = document.getElementById('user-input');
    const sendButton = document.getElementById('send-button');
    const modelSelect = document.getElementById('model-select');
    
    // Bottom input area elements
    const bottomInputArea = document.getElementById('bottom-input-area');
    const userInputBottom = document.getElementById('user-input-bottom');
    const sendButtonBottom = document.getElementById('send-button-bottom');

    // Backend API URL - make sure this matches your backend server
    const API_URL = 'http://localhost:8888/api/chat';
    const WS_URL = 'ws://localhost:8888/api/chat/ws';
    const MODEL_STATUS_URL = 'http://localhost:8888/api/models/status';
    
    // Track model pulling state
    let isPullingModel = false;

    // Initialize WebSocket connection
    let socket;
    let isConnected = false;
    
    function connectWebSocket() {
        socket = new WebSocket(WS_URL);
        
        socket.onopen = function() {
            console.log('WebSocket connection established');
            isConnected = true;
        };
        
        socket.onmessage = function(event) {
            console.log('Message received from server:', event.data);
            
            // Check if this is a status message about model pulling
            const message = event.data;
            if (message.includes('is not installed. Pulling it now')) {
                isPullingModel = true;
                showModelPullingIndicator(message);
                return;
            } else if (message.includes('Successfully pulled model')) {
                isPullingModel = false;
                hideModelPullingIndicator();
                checkModelStatus(); // Refresh model status
                addMessage('Model successfully downloaded and ready to use!', false);
                return;
            } else if (message.includes('Failed to pull model')) {
                isPullingModel = false;
                hideModelPullingIndicator();
                addMessage(message, false);
                return;
            }
            
            removeTypingIndicator();
            addMessage(message, false);
        };
        
        socket.onclose = function() {
            console.log('WebSocket connection closed');
            isConnected = false;
            // Try to reconnect after a delay
            setTimeout(connectWebSocket, 3000);
        };
        
        socket.onerror = function(error) {
            console.error('WebSocket error:', error);
            isConnected = false;
        };
    }
    
    // Connect to WebSocket when page loads
    connectWebSocket();
    
    // Function to check model installation status
    async function checkModelStatus() {
        try {
            const response = await fetch(MODEL_STATUS_URL);
            if (response.ok) {
                const data = await response.json();
                console.log('Model status:', data);
                
                // Mark installed models in the dropdown
                data.models.forEach(model => {
                    const option = Array.from(modelSelect.options).find(opt => opt.value === model.name);
                    if (option) {
                        if (model.installed) {
                            option.text = option.text.replace(' (Not Installed)', '') + ' ✓';
                        } else {
                            option.text = option.text.replace(' ✓', '') + ' (Not Installed)';
                        }
                    }
                });
                
                // Set current model if different from selected
                if (data.current_model && modelSelect.value !== data.current_model) {
                    modelSelect.value = data.current_model;
                }
            }
        } catch (error) {
            console.error('Error checking model status:', error);
        }
    }
    
    // Check model status on load
    checkModelStatus();

    // Configure marked.js with better code highlighting options
    marked.setOptions({
        highlight: function(code, lang) {
            if (lang && hljs.getLanguage(lang)) {
                return hljs.highlight(code, { language: lang }).value;
            }
            return hljs.highlightAuto(code).value;
        },
        breaks: true,
        gfm: true,
        pedantic: false,
        sanitize: false,
        smartLists: true,
        smartypants: false
    });

    // Override the renderer to add line numbers to code blocks
    const renderer = new marked.Renderer();
    const originalCodeRenderer = renderer.code;
    renderer.code = function(code, language, isEscaped) {
        return originalCodeRenderer.call(this, code, language, isEscaped);
    };

    marked.use({ renderer });

    // Function to hide the center content and show bottom input on first message
    function hideCenterContent() {
        const centerContent = document.querySelector('.center-content');
        if (centerContent && !centerContent.classList.contains('hide')) {
            centerContent.classList.add('hide');
            
            // Show bottom input area
            if (bottomInputArea) {
                bottomInputArea.style.display = 'flex';
                chatMessages.classList.add('with-bottom-input');
            }
        }
    }

    // Function to add a message to the chat
    function addMessage(content, isUser = false) {
        // Hide center content when first message is added
        hideCenterContent();
        
        const messageRow = document.createElement('div');
        messageRow.className = `message-row ${isUser ? 'user' : 'bot'}`;

        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${isUser ? 'user' : 'bot'}`;

        const messageContainer = document.createElement('div');
        messageContainer.className = 'message-container';

        // Create avatar
        const avatar = document.createElement('div');
        avatar.className = isUser ? 'user-avatar' : 'bot-avatar';
        avatar.textContent = isUser ? 'U' : 'AI';

        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content markdown-body';

        // Use markdown parsing for both user and bot messages
        contentDiv.innerHTML = marked.parse(content);

        // Apply syntax highlighting to code blocks
        contentDiv.querySelectorAll('pre code').forEach((block) => {
            hljs.highlightElement(block);

            // Add copy button to each code block (for both user and bot messages)
            const preElement = block.parentElement;
            const codeBlockWrapper = document.createElement('div');
            codeBlockWrapper.className = 'code-block-wrapper';
            codeBlockWrapper.style.position = 'relative';

            // Get the language from the class
            const languageClass = Array.from(block.classList).find(cls => cls.startsWith('language-'));
            if (languageClass) {
                const language = languageClass.replace('language-', '');
                codeBlockWrapper.setAttribute('data-language', language);
            }

            // Create copy button for this code block
            const copyCodeButton = document.createElement('button');
            copyCodeButton.className = 'copy-button code-copy-button';
            copyCodeButton.textContent = 'Copy';
            copyCodeButton.title = 'Copy code to clipboard';

            // Add click event to copy just this code block
            copyCodeButton.addEventListener('click', function(e) {
                e.stopPropagation(); // Prevent event bubbling

                // Get the text content of just this code block
                const codeText = block.textContent;

                // Copy to clipboard
                navigator.clipboard.writeText(codeText).then(function() {
                    copyCodeButton.textContent = 'Copied!';
                    copyCodeButton.classList.add('copy-success');

                    setTimeout(function() {
                        copyCodeButton.textContent = 'Copy';
                        copyCodeButton.classList.remove('copy-success');
                    }, 2000);
                }).catch(function(err) {
                    console.error('Could not copy code: ', err);
                    copyCodeButton.textContent = 'Error!';

                    setTimeout(function() {
                        copyCodeButton.textContent = 'Copy';
                    }, 2000);
                });
            });

            // Replace the pre element with our wrapper
            preElement.parentNode.insertBefore(codeBlockWrapper, preElement);
            codeBlockWrapper.appendChild(preElement);
            codeBlockWrapper.appendChild(copyCodeButton);
        });

        messageContainer.appendChild(avatar);
        messageContainer.appendChild(contentDiv);
        messageDiv.appendChild(messageContainer);

        // Only add the "Copy All" button to bot messages
        if (!isUser) {
            // Add copy button for the entire bot message
            const copyButton = document.createElement('button');
            copyButton.className = 'copy-button';
            copyButton.textContent = 'Copy All';
            copyButton.title = 'Copy entire message to clipboard';
            copyButton.addEventListener('click', function() {
                // Copy the original markdown content to clipboard
                navigator.clipboard.writeText(content).then(function() {
                    // Visual feedback for successful copy
                    copyButton.textContent = 'Copied!';
                    copyButton.classList.add('copy-success');

                    // Reset button text after 2 seconds
                    setTimeout(function() {
                        copyButton.textContent = 'Copy All';
                        copyButton.classList.remove('copy-success');
                    }, 2000);
                }).catch(function(err) {
                    console.error('Could not copy text: ', err);
                    copyButton.textContent = 'Error!';

                    // Reset button text after 2 seconds
                    setTimeout(function() {
                        copyButton.textContent = 'Copy All';
                    }, 2000);
                });
            });

            messageDiv.appendChild(copyButton);
        }

        messageRow.appendChild(messageDiv);
        chatMessages.appendChild(messageRow);

        // Scroll to the bottom of the chat
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Function to show typing indicator
    function showTypingIndicator() {
        const indicator = document.createElement('div');
        indicator.className = 'typing-indicator';
        indicator.id = 'typing-indicator';

        for (let i = 0; i < 3; i++) {
            const dot = document.createElement('span');
            indicator.appendChild(dot);
        }

        chatMessages.appendChild(indicator);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Function to remove typing indicator
    function removeTypingIndicator() {
        const indicator = document.getElementById('typing-indicator');
        if (indicator) {
            indicator.remove();
        }
    }
    
    // Function to show model pulling indicator
    function showModelPullingIndicator(message) {
        // Remove any existing indicators
        hideModelPullingIndicator();
        removeTypingIndicator();
        
        // Disable UI elements
        sendButton.disabled = true;
        modelSelect.disabled = true;
        userInput.disabled = true;
        userInput.placeholder = 'Downloading model, please wait...';
        
        // Create a special pulling indicator
        const indicator = document.createElement('div');
        indicator.className = 'model-pulling-indicator';
        indicator.id = 'model-pulling-indicator';
        indicator.innerHTML = `
            <div class="pulling-content">
                <div class="spinner"></div>
                <div class="pulling-text">${message}</div>
                <div class="pulling-note">This may take several minutes depending on model size and internet speed...</div>
            </div>
        `;
        
        chatMessages.appendChild(indicator);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }
    
    // Function to hide model pulling indicator
    function hideModelPullingIndicator() {
        const indicator = document.getElementById('model-pulling-indicator');
        if (indicator) {
            indicator.remove();
        }
        
        // Re-enable UI elements
        sendButton.disabled = false;
        modelSelect.disabled = false;
        userInput.disabled = false;
        userInput.placeholder = 'What do you want to know?';
    }

    // Function to send a message to the backend
    async function sendMessage(message) {
        try {
            showTypingIndicator();
            
            // Get the currently selected model
            // Interfaces with the frontend and sends the message to the backend
            const selectedModel = modelSelect.value;
            console.log(`Sending message with model: ${selectedModel}`);
            
            // Use WebSocket if connected, otherwise fall back to HTTP
            if (isConnected && socket.readyState === WebSocket.OPEN) {
                // Send via WebSocket
                socket.send(JSON.stringify({
                    message: message,
                    model_name: selectedModel
                }));
            } else {
                // Send via HTTP as fallback
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        message: message,
                        model_name: selectedModel
                    }),
                });

                if (!response.ok) {
                    removeTypingIndicator();
                    addMessage(`Error: Server returned status ${response.status}`, false);
                    return;
                }

                const data = await response.json();
                removeTypingIndicator();

                // Add the bot's response to the chat
                addMessage(data.response, false);
            }
        } catch (error) {
            console.error('Error sending message:', error);
            removeTypingIndicator();
            addMessage('Sorry, there was an error processing your request. Please try again.', false);
        }
    }

    // Event listener for send button
    sendButton.addEventListener('click', function() {
        const message = userInput.value.trim();
        if (message) {
            // Add user message to chat
            addMessage(message, true);

            // Clear input field
            userInput.value = '';

            // Send message to backend
            sendMessage(message);
        }
    });

    // Event listener for Enter key in input field
    userInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendButton.click();
        }
    });

    // Auto-resize textarea as user types
    userInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });
    
    // Bottom input area - auto-resize
    if (userInputBottom) {
        userInputBottom.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
        });
    }
    
    // Bottom input area - send button
    if (sendButtonBottom) {
        sendButtonBottom.addEventListener('click', function() {
            const message = userInputBottom.value.trim();
            if (message) {
                // Add user message to chat
                addMessage(message, true);
                
                // Clear input field
                userInputBottom.value = '';
                userInputBottom.style.height = 'auto';
                
                // Send message to backend
                sendMessage(message);
            }
        });
    }
    
    // Bottom input area - Enter key
    if (userInputBottom) {
        userInputBottom.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendButtonBottom.click();
            }
        });
    }

    // Initialize model selector
    if (!modelSelect.value || modelSelect.value === 'auto') {
        modelSelect.value = 'llama3.1'; // Set default model
    }
    
    // Add visual feedback when model is changed
    modelSelect.addEventListener('change', function() {
        const selectedModel = this.value;
        console.log(`Model changed to: ${selectedModel}`);
        
        // Check if model needs to be installed
        const selectedOption = this.options[this.selectedIndex];
        if (selectedOption.text.includes('(Not Installed)')) {
            // Model needs to be pulled - it will be pulled when user sends first message
            const notification = document.createElement('div');
            notification.className = 'model-change-notification';
            notification.textContent = `Model ${selectedOption.text} will be downloaded when you send a message`;
            notification.style.backgroundColor = '#f59e0b'; // Warning color
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.opacity = '0';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        } else {
            // Model is ready to use
            const notification = document.createElement('div');
            notification.className = 'model-change-notification';
            notification.textContent = `Switched to ${this.options[this.selectedIndex].text}`;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.opacity = '0';
                setTimeout(() => notification.remove(), 300);
            }, 2000);
        }
    });

    // Action buttons functionality
    const actionButtons = document.querySelectorAll('.action-button');
    actionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const action = this.getAttribute('title');
            // These are placeholders - you can implement actual functionality
            console.log(`Action button clicked: ${action}`);
            
            switch(action) {
                case 'Deep Search':
                    userInput.value = '[Deep Search Mode] ';
                    userInput.focus();
                    break;
                case 'Create Image':
                    userInput.value = 'Create an image of ';
                    userInput.focus();
                    break;
                case 'Pick Personas':
                    // Could open a persona selector modal
                    break;
                case 'Voice':
                    // Could toggle voice input
                    break;
            }
        });
    });

    const previewToggle = document.getElementById('preview-toggle');
    const markdownPreview = document.getElementById('markdown-preview');
    let previewActive = false;

    // Toggle markdown preview
    if (previewToggle && markdownPreview) {
        previewToggle.addEventListener('click', function() {
            previewActive = !previewActive;

            if (previewActive) {
                // Update preview content
                markdownPreview.innerHTML = marked.parse(userInput.value);

                // Apply syntax highlighting
                markdownPreview.querySelectorAll('pre code').forEach((block) => {
                    hljs.highlightElement(block);
                });

                // Show preview
                markdownPreview.classList.add('active');
                userInput.style.opacity = '0';
            } else {
                // Hide preview
                markdownPreview.classList.remove('active');
                userInput.style.opacity = '1';
            }
        });

        // Update preview when typing
        userInput.addEventListener('input', function() {
            if (previewActive) {
                markdownPreview.innerHTML = marked.parse(userInput.value);

                // Apply syntax highlighting
                markdownPreview.querySelectorAll('pre code').forEach((block) => {
                    hljs.highlightElement(block);
                });
            }
        });
    }

    // Markdown toolbar functionality
    const toolbarButtons = document.querySelectorAll('.toolbar-button');

    toolbarButtons.forEach(button => {
        button.addEventListener('click', function() {
            const format = this.getAttribute('data-format');
            const textarea = document.getElementById('user-input');
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            const selectedText = textarea.value.substring(start, end);
            let replacement = '';

            switch(format) {
                case 'bold':
                    replacement = `**${selectedText}**`;
                    break;
                case 'italic':
                    replacement = `*${selectedText}*`;
                    break;
                case 'code':
                    replacement = `\`${selectedText}\``;
                    break;
                case 'codeblock':
                    replacement = '```\n' + selectedText + '\n```';
                    break;
            }

            // Insert the formatted text back into the textarea
            textarea.value = textarea.value.substring(0, start) + replacement + textarea.value.substring(end);
            textarea.focus();
            textarea.selectionStart = start + replacement.length;
            textarea.selectionEnd = start + replacement.length;
        });
    });
});
