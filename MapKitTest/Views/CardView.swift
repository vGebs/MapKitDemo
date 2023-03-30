//
//  CardView.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-29.
//

import Foundation
import SwiftUI

struct CardView: View {
    @ObservedObject var viewModel: MapViewModel
    @Binding var cardState: SwipeableCardView<CardView>.CardState // Add this line

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.cyan)
            
            VStack {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: screenHeight * 0.15, height: screenHeight * 0.005)
                        .padding(.top)
                    Spacer()
                }
                
                SearchBar(text: $viewModel.searchQuery,
                          onEdit: { newVal in viewModel.updateSearchQuery(query: newVal) },
                          onFocused: { focused in
                    if focused {
                        withAnimation {
                            cardState = .high
                        }
                    }
                }, onCancelled: {
                    cardState = .mid
                })
                .padding(.top, 5)
                .padding(.horizontal)
                
//                List(viewModel.searchResults, id: \.self) { result in
//                    Button(action: {
//                        viewModel.search(query: result.title)
//                    }) {
//                        Text(result.title)
//                            .foregroundColor(.white)
//                    }
//                }
//                .cornerRadius(20)
//                .padding(.horizontal)
//                .padding(.bottom)
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .cornerRadius(20)
    }
}
