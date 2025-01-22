//
//  AddItemView.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//

import SwiftUI

struct AddItemView: View {
    @ObservedObject var itemManager: ItemManager
    @Binding var isPresented: Bool
    @Binding var selectedTagIds: Set<UUID>
    @ObservedObject var tagManager: TagManager
    var onItemAdded: (Item) -> Void
    var onAvailableItem: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName: String = ""
    @State private var itemQuantity: String = ""
    @State private var itemPrice: String = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var newTag: String = ""
    @State private var showAddTagView = false
    
    private var isFormValid: Bool {
        ![itemName, itemQuantity, itemPrice].contains(where: \.isEmpty)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("新しいアイテムを追加")
                .font(.headline)
                .padding(.top)
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "cart")
                        .foregroundColor(.blue)
                    TextField("商品名", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                    TextField("数量", text: $itemQuantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                HStack {
                    Image(systemName: "yensign.circle")
                        .foregroundColor(.blue)
                    TextField("商品単価", text: $itemPrice)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("タグ")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button(action: {
                                showAddTagView = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            ForEach(tagManager.tags, id: \.self) { tag in
                                TagView(tag: tag, isSelected: selectedTags.contains(tag.id)) {
                                    if selectedTags.contains(tag.id) {
                                        selectedTags.remove(tag.id)
                                    } else {
                                        selectedTags.insert(tag.id)
                                    }
                                } onDelete: {
                                    deleteTag(tag)
                                }
                            }
                            .padding(.vertical,1)
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.vertical, 5)
                

                
                Button(action: addItem) {
                    Text("追加")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(!isFormValid)
                
                
                Spacer()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAddTagView) {
            AddTagView(
                tagManager: tagManager,
                onAvailableItem: { _ in }
            )
        }
    }
    
    private func addItem() {
        if let quantity = Int(itemQuantity), let price = Int(itemPrice) {
            if itemManager.items.contains(where: { $0.name.lowercased() == itemName.lowercased() }) {
                onAvailableItem(itemName)
            } else {
                let newItem = Item(name: itemName, quantity: quantity, price: price, tagIds: Array(selectedTags))
                itemManager.addItem(newItem)
                onItemAdded(newItem)
            }
        }
        dismiss()
    }
    
    private func deleteTag(_ tag: Tag) {
        tagManager.removeTag(tag)
        selectedTags.remove(tag.id)
    }
}

#Preview {
    AddItemView(itemManager: ItemManager(),isPresented: .constant(true), selectedTagIds: .constant([]), tagManager: TagManager(), onItemAdded: { _ in }, onAvailableItem: { _ in })
}
