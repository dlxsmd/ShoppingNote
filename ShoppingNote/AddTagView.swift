//
//  AddTagView.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//

import SwiftUI

struct AddTagView: View {
    @ObservedObject var tagManager: TagManager
    @State private var tagName = ""
    @State private var tagColor = Color.blue
    @State private var isSelected = false
    @Environment(\.dismiss) private var dismiss
    var onAvailableItem: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("新しいタグを追加")
                .font(.headline)
                .padding(.top)
            
            // Preview tag area
            TagView(tag: Tag(name: tagName.isEmpty ? "タグ名" : tagName, color: tagColor), isSelected: isSelected, action: { isSelected.toggle() }, onDelete: {})
                .padding(.vertical)
            

            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.blue)
                    TextField("タグ名", text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Image(systemName: "paintpalette")
                        .foregroundColor(.blue)
                    ColorPicker("タグの色", selection: $tagColor)
                }
            }
            .padding(.horizontal)

            Button(action: {
                checkAvailableItem()
                dismiss()
            }) {
                Text("追加")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!tagName.isEmpty ? Color.blue : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(tagName.isEmpty)
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(30)
    }
    
    private func checkAvailableItem() {
        let newTag = Tag(name: tagName, color: tagColor)
        if tagManager.tags.contains(where: { $0.name.lowercased() == tagName.lowercased() }) {
            onAvailableItem(tagName)
        } else {
            tagManager.addTag(newTag)
        }
    }
}


#Preview {
    AddTagView(tagManager: TagManager(), onAvailableItem: { _ in })
}
