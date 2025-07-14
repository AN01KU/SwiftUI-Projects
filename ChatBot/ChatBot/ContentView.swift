//
//  ContentView.swift
//  ChatBot
//
//  Created by Ankush Ganesh on 12/07/25.
//

import SwiftUI
import OpenAI

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    
    let openAI = OpenAI(apiToken: "some-api-token")
    
    func sendMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getBotReply()
        
    }
    
    func getBotReply() {
        _ = openAI.chats(query: .init(messages: messages.compactMap({ChatQuery.ChatCompletionMessageParam(role: .user, content: $0.content)}), model: .gpt3_5Turbo)) { result in
            switch result {
            case .success(let success):
                guard let choice = success.choices.first else { return }
                guard let message = choice.message.content else { return }
                DispatchQueue.main.async {
                    self.messages.append(.init(content: message, isUser: false))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

struct ContentView: View {
    
    @State var chatController: ChatController = .init()
    @State var string: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatController.messages) {
                    message in
                    MessageView(message: message)
                        .padding(5)
                }
            }
            Divider()
            HStack {
                TextField("Message ...", text: $string, axis: .vertical)
                    .padding(5)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                Button {
                    self.chatController.sendMessage(content: string)
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
    }
}

struct MessageView: View {
    var message: Message
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            } else {
                HStack {

                    Text(message.content)
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
