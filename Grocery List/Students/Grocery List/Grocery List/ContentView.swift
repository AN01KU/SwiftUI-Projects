//
//  ContentView.swift
//  Grocery List
//
//  Created by Ankush Ganesh on 09/06/25.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var item: String = ""
    
    @FocusState private var isFocused: Bool
    
    let buttonTip = ButtonTip()
    
    func setupTips() {
        do {
            try Tips.resetDatastore()
            Tips.showAllTipsForTesting()
            try Tips.configure([
                .displayFrequency(.immediate)
            ])
        } catch {
            print("Error initializing TipKit: \(error.localizedDescription)")
        }
    }
    
    init() {
        setupTips()
    }
    
    func addEssentialFoods() {
        modelContext.insert(Item(title: "Cheese & Eggs", isCompleted: true))
        modelContext.insert(Item(title: "Meat & Seafood", isCompleted: false))
        modelContext.insert(Item(title: "Cerals", isCompleted: .random()))
        modelContext.insert(Item(title: "Pasta & Rice", isCompleted: .random()))
        modelContext.insert(Item(title: "Bakery & Bread", isCompleted: .random()))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.title)
                        .fontWeight(.light)
                        .padding(.vertical, 2)
                        .foregroundStyle(item.isCompleted == false ? Color.primary : Color.accentColor)
                        .strikethrough(item.isCompleted)
                        .italic(item.isCompleted)
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Done", systemImage: item.isCompleted == false ? "checkmark.circle" : "x.circle") {
                                item.isCompleted.toggle()
                            }
                            .tint(item.isCompleted == false ? .green : .accentColor)
                        }
                }
            } //: List
            .navigationTitle("Grocery Title")
            .toolbar {
                if items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            addEssentialFoods()
                        } label: {
                            Image(systemName: "carrot")
                        }
                        .popoverTip(buttonTip)
                    }
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Empty Cart", systemImage: "cart.circle", description: Text("Add some items to the shopping list."))
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    TextField("", text: $item)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.tertiary)
                        .clipShape(.rect(cornerRadius: 12))
                        .font(.title.weight(.light))
                        .focused($isFocused)
                    Button {
                        guard !item.isEmpty else { return }
                        let newItem = Item(title: item)
                        modelContext.insert(newItem)
                        item = ""
                        isFocused = false
                    } label: {
                        Text("Save")
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity)
                            
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.extraLarge)
                }
                .padding()
                .background(.bar)
            }
        } //: NavigationStack
    }
}

#Preview("Sample Data") {
    let sampleData: [Item] = [
        Item(title: "Cheese & Eggs", isCompleted: true),
        Item(title: "Meat & Seafood", isCompleted: false),
        Item(title: "Cerals", isCompleted: .random()),
        Item(title: "Pasta & Rice", isCompleted: .random()),
        Item(title: "Bakery & Bread", isCompleted: .random()),
    ]
    let container = try! ModelContainer(for: Item.self, configurations: .init(isStoredInMemoryOnly: true))
    for item in sampleData {
        container.mainContext.insert(item)
    }
    
    return ContentView()
        .modelContainer(container)
}

#Preview("Empty List") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
