//
//  ContentView.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/03.
//

import SwiftUI

enum AlertType: Identifiable {
    case delete(String)
    case add(String)
    case clearConfirmation
    case available(String)

    var id: Int {
        switch self {
        case .delete: return 0
        case .add: return 1
        case .clearConfirmation: return 2
        case .available: return 3
        }
    }
}

enum SheetType: Identifiable {
    case addItem
    case addTag
    case editItem(Item)

    var id: Int {
        switch self {
        case .addItem: return 0
        case .addTag: return 1
        case .editItem: return 2
        }
    }
}

enum SortOption: Equatable {
    case price(ascending: Bool)
    case createdDate(ascending: Bool)
    case updatedDate(ascending: Bool)
    case totalAmount(ascending: Bool)
}

struct ContentView: View {
    @StateObject private var itemManager: ItemManager
    @StateObject private var tagManager: TagManager
    @State private var activeAlert: AlertType?
    @State private var activeSheet: SheetType?
    @State private var searchText = ""
    @State private var selectedTagIds: Set<UUID> = []
    @State private var isAddTag: Bool = false
    @State private var isAddItem: Bool = false
    @State private var currentSortOption: SortOption = .createdDate(ascending: false)

    // MARK: computed property
    private var totalQuantity: Int {
        filteredItems.map({ $0.quantity }).reduce(0, +)
    }

    private var totalPrice: Int {
        filteredItems.map({ $0.quantity * $0.price }).reduce(0, +)
    }

    private var filteredItems: [Item] {
        let filtered = itemManager.items.filter { item in
            let matchesSearchText = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            let matchesTags = selectedTagIds.isEmpty || !Set(item.tagIds).isDisjoint(with: selectedTagIds)
            return matchesSearchText && matchesTags
        }
        
        switch currentSortOption {
        case .price(let ascending):
            return filtered.sorted { ascending ? $0.price < $1.price : $0.price > $1.price }
        case .createdDate(let ascending):
            return filtered.sorted { ascending ? $0.createdDate < $1.createdDate : $0.createdDate > $1.createdDate }
        case .updatedDate(let ascending):
            return filtered.sorted { ascending ? $0.updatedDate < $1.updatedDate : $0.updatedDate > $1.updatedDate }
        case .totalAmount(let ascending):
            return filtered.sorted { ascending ? $0.price * $0.quantity < $1.price * $1.quantity : $0.price * $0.quantity > $1.price * $1.quantity }
        }
    }
    
    private var isAscending: Bool {
        switch currentSortOption {
        case .price(let ascending),
             .createdDate(let ascending),
             .updatedDate(let ascending),
             .totalAmount(let ascending):
            return ascending
        }
    }
    
    // MARK: initializer for mock data injection
    init(itemManager: ItemManager = ItemManager(), tagManager: TagManager = TagManager()) {
        _itemManager = StateObject(wrappedValue: itemManager)
        _tagManager = StateObject(wrappedValue: tagManager)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if !itemManager.items.isEmpty {
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tagManager.tags) { tag in
                                    TagView(tag: tag, isSelected: selectedTagIds.contains(tag.id)) {
                                        if selectedTagIds.contains(tag.id) {
                                            selectedTagIds.remove(tag.id)
                                        } else {
                                            selectedTagIds.insert(tag.id)
                                        }
                                    } onDelete: {
                                        deleteTag(tag)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical,1)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    itemView(item)
                                }
                                Color.clear.frame(height: 50)
                            }
                            .padding()
                        }

                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                        .listStyle(PlainListStyle())
                    }

                    VStack {
                        HStack {
                            Text("合計:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(totalQuantity)点")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(totalPrice)円")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                } else {
                    Text("商品がありません")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .addTag
                    }) {
                        Image(systemName: "tag.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .addItem
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showClearConfirmationAlert()
                    }) {
                        Image(systemName: "trash")
                    }.disabled(itemManager.items.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { currentSortOption = .price(ascending: currentSortOption == .price(ascending: false)) }) {
                            Label("単価順", systemImage: "yensign.circle")
                        }
                        Button(action: { currentSortOption = .createdDate(ascending: currentSortOption == .createdDate(ascending: false)) }) {
                            Label("追加日順", systemImage: "calendar")
                        }
                        Button(action: { currentSortOption = .updatedDate(ascending: currentSortOption == .updatedDate(ascending: false)) }) {
                            Label("更新日順", systemImage: "clock")
                        }
                        Button(action: { currentSortOption = .totalAmount(ascending: currentSortOption == .totalAmount(ascending: false)) }) {
                            Label("合計金額順", systemImage: "sum")
                        }
                    } label: {
                        Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("🛒買い物メモ")
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .addItem:
                AddItemView(
                    itemManager: itemManager,
                    isPresented: $isAddItem,
                    selectedTagIds: $selectedTagIds,
                    tagManager: tagManager,
                    onItemAdded: { newItem in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeAlert = .add(newItem.name)
                        }
                    },
                    onAvailableItem: { availableName in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeAlert = .available(availableName)
                        }
                    }
                )
            case .addTag:
                AddTagView(
                    tagManager: tagManager,
                    onAvailableItem: { availableName in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeAlert = .available(availableName)
                        }
                    }
                )
            case .editItem(let item):
                EditItemView(item: $itemManager.items[itemManager.items.firstIndex(where: { $0.id == item.id })!], itemManager: itemManager, tagManager: tagManager
                )
            }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .delete(let name):
                return Alert(title: Text("\(name)を削除しました"))
            case .add(let name):
                return Alert(title: Text("\(name)を追加しました"))
            case .clearConfirmation:
                return Alert(title: Text("表示中の全ての商品を削除しますか？"),
                             primaryButton: .destructive(Text("削除"), action: {
                                for item in filteredItems {
                                    itemManager.removeItem(item)
                                }
                             }),
                             secondaryButton: .cancel()
                )
            case .available(let name):
                return Alert(title: Text("\(name)は既に追加されています"))
            }
        }
    }
    
    // MARK: ViewBuilder to avoid type checking errors
    @ViewBuilder
    private func itemView(_ item: Item) -> some View {
        let itemTotal = item.price * item.quantity

        Button( action: { activeSheet = .editItem(item) }, label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    HStack(spacing: 4) {
                        Text("\(item.quantity)個")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("@\(item.price)円")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(itemTotal)円")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("小計")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive,action: {
                deleteItem(at: IndexSet([itemManager.items.firstIndex(where: { $0.id == item.id })!]))
            }) {
                Label("削除", systemImage: "trash")
            }
        }
    }
    private func deleteItem(at offsets: IndexSet) {
        let itemToDelete = itemManager.items[offsets.first!]
        showDeleteAlert(for: itemToDelete.name)
        itemManager.removeItem(itemToDelete)
    }

    private func showDeleteAlert(for name: String) {
        activeAlert = .delete(name)
    }

    private func showClearConfirmationAlert() {
        activeAlert = .clearConfirmation
    }

    private func deleteTag(_ tag: Tag) {
        tagManager.removeTag(tag)
        selectedTagIds.remove(tag.id)
    }
}

#Preview {
    ContentView()
}

// MARK: Mock Data
let mockItems = [
    Item(name: "りんご", quantity: 2, price: 100, tagIds: []),
    Item(name: "バナナ", quantity: 3, price: 80, tagIds: []),
    Item(name: "牛乳", quantity: 1, price: 200, tagIds: []),
    Item(name: "コーヒー", quantity: 1, price: 150, tagIds: []),
    Item(name: "パン", quantity: 3, price: 120, tagIds: []),
    Item(name: "卵", quantity: 10, price: 20, tagIds: []),
    Item(name: "お茶", quantity: 2, price: 100, tagIds: []),
    Item(name: "トマト", quantity: 3, price: 50, tagIds: []),
    Item(name: "じゃがいも", quantity: 5, price: 30, tagIds: []),
    Item(name: "にんじん", quantity: 4, price: 40, tagIds: [])
]

let mockTags = [
    Tag(name: "果物", color: .red),
    Tag(name: "飲み物", color: .blue)
]


