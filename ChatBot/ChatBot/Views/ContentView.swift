//
//  ContentView.swift
//  ChatBot
//
//  Created by Ankush Ganesh on 12/07/25.
//

import SwiftUI

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false
    
    // Initialize Ollama client with localhost
    private let ollama = OllamaClient(baseURL: "http://localhost:11434")
    private let modelName = "deepseek-r1:14b"
    
    func sendMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getBotReply()
    }
    
    func getBotReply() {
        isTyping = true
        
        // Convert messages to Ollama format
        let ollamaMessages = messages.map { message in
            OllamaClient.createMessage(
                role: message.isUser ? "user" : "assistant",
                content: message.content
            )
        }
        
        // Configure options
        let options = OllamaOptions(
            temperature: 0.7,
            topP: 0.9,
            topK: 40,
            numPredict: 1000
        )
        
        ollama.chat(
            model: modelName,
            messages: ollamaMessages,
            options: options
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isTyping = false
                switch result {
                case .success(let response):
                    let botMessage = Message(content: response.message.content, isUser: false)
                    self?.messages.append(botMessage)
                case .failure(let error):
                    print("Ollama API Error: \(error)")
                    let errorMessage = Message(content: "Sorry, I encountered an error: \(error.localizedDescription)", isUser: false)
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
    
    // Method to clear conversation
    func clearMessages() {
        messages.removeAll()
    }
    
    // Method to check if model is available
    func checkModelAvailability(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:11434/api/tags")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Connection test failed: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
            }
            
            // Test actual chat
            let testMessages = [OllamaClient.createMessage(role: "user", content: "Hello")]
            
            self.ollama.chat(model: self.modelName, messages: testMessages) { result in
                switch result {
                case .success(let response):
                    print("Model test successful: \(response.message.content)")
                    completion(true)
                case .failure(let error):
                    print("Model test failed: \(error)")
                    completion(false)
                }
            }
        }.resume()
    }
}

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
    var timestamp: Date = Date()
}

struct ContentView: View {
    @StateObject var chatController: ChatController = .init()
    @State var messageText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatController.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                            
                            // Typing indicator
                            if chatController.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .onChange(of: chatController.messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(chatController.messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: chatController.isTyping) { _ in
                        if chatController.isTyping {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    HStack(alignment: .bottom, spacing: 12) {
                        // Text Input
                        HStack {
                            TextField("Type a message...", text: $messageText, axis: .vertical)
                                .focused($isTextFieldFocused)
                                .font(.system(size: 16))
                                .lineLimit(1...6)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        
                        // Send Button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatController.isTyping)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        chatController.clearMessages()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        chatController.sendMessage(content: trimmedMessage)
        messageText = ""
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        // Bot Avatar
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        
                        Text(message.content)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(18)
                            .cornerRadius(18, corners: [.topRight, .bottomLeft, .bottomRight])
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 40)
                }
                
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicatorView: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 8) {
                // Bot Avatar
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                
                // Typing animation
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationAmount == Double(index) ? 1.2 : 0.8)
                            .opacity(animationAmount == Double(index) ? 1.0 : 0.5)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
                        withAnimation(.easeInOut(duration: 0.6)) {
                            animationAmount = animationAmount == 2.0 ? 0.0 : animationAmount + 1.0
                        }
                    }
                }
            }
            
            Spacer(minLength: 60)
        }
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ContentView()
}
