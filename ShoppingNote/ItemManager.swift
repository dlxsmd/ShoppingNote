//
//  ItemManager.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//

import SwiftUI

struct Item: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var quantity: Int
    var price: Int
    var tagIds: [UUID]
    let createdDate: Date
    var updatedDate: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(),name: String, quantity: Int, price: Int, tagIds: [UUID] = [], createdDate: Date = Date(), updatedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
        self.tagIds = tagIds
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
}

class ItemManager: ObservableObject {
    @Published var items: [Item] = []
    
    init() {
        loadItems()
    }
    
    init(items: [Item] = []) {
        self.items = items
    }
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
    }
    
    func removeItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        } else {
            print("Failed to find item with id \(item.id)")
        }
    }
    
    private func saveItems() {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: "savedItems")
        } catch {
            print("Failed to save items:", error.localizedDescription)
        }
    }
    
    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "savedItems"),
           let decodedItems = try? JSONDecoder().decode([Item].self, from: savedItems) {
            items = decodedItems
        }
    }
}

