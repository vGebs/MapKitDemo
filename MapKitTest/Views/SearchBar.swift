//
//  SearchBar.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-29.
//

import Foundation
import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    var onEdit: (String) -> Void = { _ in }
    
    init(text: Binding<String>, onEdit: @escaping (String) -> Void = { _ in }) {
        self._text = text
        self.onEdit = onEdit
    }
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text, onEditingChanged: { isEditing in
                self.isEditing = isEditing
            })
            .onChange(of: text) { newValue in
                onEdit(newValue)
            }
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if isEditing {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .onTapGesture {
                self.isEditing = true
            }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
