//
//  EditItemView.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//

import SwiftUI

struct EditItemView: View {
    @Binding var item: Item
    @ObservedObject var itemManager: ItemManager
    @ObservedObject var tagManager: TagManager
    @State private var editedName: String
    @State private var editedQuantity: Int
    @State private var editedPrice: Int
    @State private var selectedTagIds: Set<UUID>
    @Environment(\.dismiss) private var dismiss

    init(item: Binding<Item>, itemManager: ItemManager, tagManager: TagManager) {
        self._item = item
        self.itemManager = itemManager
        self.tagManager = tagManager
        self._editedName = State(initialValue: item.wrappedValue.name)
        self._editedQuantity = State(initialValue: item.wrappedValue.quantity)
        self._editedPrice = State(initialValue: item.wrappedValue.price)
        self._selectedTagIds = State(initialValue: Set(item.wrappedValue.tagIds))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("商品を編集")
                .font(.headline)
                .padding(.top)

            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "cart")
                        .foregroundColor(.blue)
                    TextField("商品名", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                    TextField("数量", value: $editedQuantity, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                HStack {
                    Image(systemName: "yensign.circle")
                        .foregroundColor(.blue)
                    TextField("価格", value: $editedPrice, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("タグ")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tagManager.tags) { tag in
                                TagView(
                                    tag: tag,
                                    isSelected: selectedTagIds.contains(tag.id),
                                    action: {
                                        if selectedTagIds.contains(tag.id) {
                                            selectedTagIds.remove(tag.id)
                                        } else {
                                            selectedTagIds.insert(tag.id)
                                        }
                                    },
                                    onDelete: {
                                        tagManager.removeTag(tag)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.horizontal)

            Button(action: saveChanges) {
                Text("保存")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
    }

    private func saveChanges() {
        item.name = editedName
        item.quantity = editedQuantity
        item.price = editedPrice
        item.tagIds = Array(selectedTagIds)
        item.updatedDate = Date()
        
        if let index = itemManager.items.firstIndex(where: { $0.id == item.id }) {
            itemManager.items[index] = item
            itemManager.updateItem(item)
        }
        dismiss()
    }
}


#Preview {
    EditItemView(
        item: .constant(Item(name: "商品", quantity: 1, price: 100)),
        itemManager: ItemManager(items: [Item(name: "商品", quantity: 1, price: 100)]),
        tagManager: TagManager(tags: [Tag(name: "タグ", color: .blue)])
    )
}


