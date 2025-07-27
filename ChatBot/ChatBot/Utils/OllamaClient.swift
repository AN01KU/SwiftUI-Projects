//
//  OllamaClient.swift
//  ChatBot
//
//  Created by Ankush Ganesh on 26/07/25.
//

import Foundation

// MARK: - Data Models
struct OllamaMessage: Codable {
    let role: String
    let content: String
}

struct OllamaChatRequest: Codable {
    let model: String
    let messages: [OllamaMessage]
    let stream: Bool
    let options: OllamaOptions?
    
    init(model: String, messages: [OllamaMessage], stream: Bool = false, options: OllamaOptions? = nil) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.options = options
    }
}

struct OllamaOptions: Codable {
    let temperature: Double?
    let top_p: Double?
    let top_k: Int?
    let num_predict: Int?
    
    init(temperature: Double? = nil, topP: Double? = nil, topK: Int? = nil, numPredict: Int? = nil) {
        self.temperature = temperature
        self.top_p = topP
        self.top_k = topK
        self.num_predict = numPredict
    }
}

struct OllamaChatResponse: Codable {
    let model: String
    let created_at: String
    let message: OllamaMessage
    let done: Bool
    let total_duration: Int?
    let load_duration: Int?
    let prompt_eval_count: Int?
    let prompt_eval_duration: Int?
    let eval_count: Int?
    let eval_duration: Int?
}

struct OllamaError: Codable, Error, LocalizedError {
    let error: String
    
    var errorDescription: String? {
        return error
    }
}

// MARK: - Ollama Client
class OllamaClient {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: String) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = URLSession.shared
    }
    
    // MARK: - Chat Completion
    func chat(
        model: String,
        messages: [OllamaMessage],
        options: OllamaOptions? = nil,
        completion: @escaping (Result<OllamaChatResponse, Error>) -> Void
    ) {
        let request = OllamaChatRequest(
            model: model,
            messages: messages,
            stream: false,
            options: options
        )
        
        performChatRequest(request: request, completion: completion)
    }
    
    // MARK: - Streaming Chat (if needed later)
    func chatStream(
        model: String,
        messages: [OllamaMessage],
        options: OllamaOptions? = nil,
        onChunk: @escaping (OllamaChatResponse) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        let request = OllamaChatRequest(
            model: model,
            messages: messages,
            stream: true,
            options: options
        )
        
        performStreamingChatRequest(request: request, onChunk: onChunk, onComplete: onComplete)
    }
    
    // MARK: - Private Methods
    private func performChatRequest(
        request: OllamaChatRequest,
        completion: @escaping (Result<OllamaChatResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("api/chat")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                // Check for ATS error and provide helpful message
                if let nsError = error as NSError?, nsError.code == -1022 {
                    let atsError = NSError(
                        domain: "OllamaClient",
                        code: -1022,
                        userInfo: [
                            NSLocalizedDescriptionKey: "App Transport Security blocked HTTP connection. Please add your Ollama server IP to NSExceptionDomains in Info.plist or use HTTPS.",
                            NSLocalizedRecoverySuggestionErrorKey: "Add \(urlRequest.url?.host ?? "your-server-ip") to NSAppTransportSecurity > NSExceptionDomains in Info.plist"
                        ]
                    )
                    completion(.failure(atsError))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OllamaClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                do {
                    let ollamaError = try JSONDecoder().decode(OllamaError.self, from: data)
                    completion(.failure(ollamaError))
                } catch {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    completion(.failure(NSError(domain: "OllamaClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
                // Clean the response content from reasoning tags
                let cleanedContent = OllamaClient.cleanResponse(response.message.content)
                let cleanedMessage = OllamaMessage(role: response.message.role, content: cleanedContent)
                let cleanedResponse = OllamaChatResponse(
                    model: response.model,
                    created_at: response.created_at,
                    message: cleanedMessage,
                    done: response.done,
                    total_duration: response.total_duration,
                    load_duration: response.load_duration,
                    prompt_eval_count: response.prompt_eval_count,
                    prompt_eval_duration: response.prompt_eval_duration,
                    eval_count: response.eval_count,
                    eval_duration: response.eval_duration
                )
                completion(.success(cleanedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func performStreamingChatRequest(
        request: OllamaChatRequest,
        onChunk: @escaping (OllamaChatResponse) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        let url = baseURL.appendingPathComponent("api/chat")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            onComplete(error)
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                onComplete(error)
                return
            }
            
            guard let data = data else {
                onComplete(NSError(domain: "OllamaClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Parse streaming response (each line is a JSON object)
            let dataString = String(data: data, encoding: .utf8) ?? ""
            let lines = dataString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            for line in lines {
                guard let lineData = line.data(using: .utf8) else { continue }
                
                do {
                    let chunk = try JSONDecoder().decode(OllamaChatResponse.self, from: lineData)
                    // For streaming, we'll clean the content as well
                    let cleanedContent = OllamaClient.cleanResponse(chunk.message.content)
                    let cleanedMessage = OllamaMessage(role: chunk.message.role, content: cleanedContent)
                    let cleanedChunk = OllamaChatResponse(
                        model: chunk.model,
                        created_at: chunk.created_at,
                        message: cleanedMessage,
                        done: chunk.done,
                        total_duration: chunk.total_duration,
                        load_duration: chunk.load_duration,
                        prompt_eval_count: chunk.prompt_eval_count,
                        prompt_eval_duration: chunk.prompt_eval_duration,
                        eval_count: chunk.eval_count,
                        eval_duration: chunk.eval_duration
                    )
                    onChunk(cleanedChunk)
                    
                    if chunk.done {
                        onComplete(nil)
                        return
                    }
                } catch {
                    // Continue processing other chunks even if one fails
                    continue
                }
            }
            
            onComplete(nil)
        }.resume()
    }
}

// MARK: - Convenience Extensions
extension OllamaClient {
    // Helper method to create messages easily
    static func createMessage(role: String, content: String) -> OllamaMessage {
        return OllamaMessage(role: role, content: content)
    }
    
    // Helper method to create user message
    static func userMessage(_ content: String) -> OllamaMessage {
        return createMessage(role: "user", content: content)
    }
    
    // Helper method to create assistant message
    static func assistantMessage(_ content: String) -> OllamaMessage {
        return createMessage(role: "assistant", content: content)
    }
    
    // Helper method to create system message
    static func systemMessage(_ content: String) -> OllamaMessage {
        return createMessage(role: "system", content: content)
    }
    
    // Helper method to clean response from reasoning tags
    private static func cleanResponse(_ content: String) -> String {
        // Remove <think>...</think> blocks from DeepSeek R1 responses
        let pattern = "<think>.*?</think>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let range = NSRange(location: 0, length: content.utf16.count)
        let cleanedContent = regex?.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "") ?? content
        
        // Trim whitespace and return
        return cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
