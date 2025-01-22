//
//  TagView.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//

import SwiftUI

struct TagView: View {
    let tag: Tag
    var isSelected: Bool
    let action: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag.name)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(tag.color.opacity(isSelected ? 0.8 : 0.3))
                .foregroundColor(isSelected ? .white : tag.color)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(tag.color, lineWidth: 1)
                )
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

#Preview {
    TagView(
        tag: Tag(name: "タグ", color: .blue),
        isSelected: false,
        action: {},
        onDelete: {}
    )
}
