//
//  TagManager.swift
//  ShoppingNote
//
//  Created by Yuki Imai on 2024/12/25.
//
import SwiftUI

struct Tag: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var colorComponents: ColorComponents
    
    var color: Color {
        Color(red: colorComponents.red, green: colorComponents.green, blue: colorComponents.blue)
    }
    
    init(name: String, color: Color) {
        self.name = name
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.colorComponents = ColorComponents(red: Double(red), green: Double(green), blue: Double(blue))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ColorComponents: Codable {
    var red: Double
    var green: Double
    var blue: Double
}




class TagManager: ObservableObject {
    @Published var tags: [Tag] = []
    
    init() {
        loadTags()
    }
    
    init(tags: [Tag] = []) {
        self.tags = tags
    }
    
    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveTags()
    }
    
    func removeTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }
    
    private func saveTags() {
        do {
            let encoded = try JSONEncoder().encode(tags)
            UserDefaults.standard.set(encoded, forKey: "savedTags")
        } catch {
            print("Failed to save tags: \(error.localizedDescription)")
        }
    }

    private func loadTags() {
        if let savedTags = UserDefaults.standard.data(forKey: "savedTags") {
            do {
                tags = try JSONDecoder().decode([Tag].self, from: savedTags)
            } catch {
                print("Failed to load tags: \(error.localizedDescription)")
            }
        }
    }

}
