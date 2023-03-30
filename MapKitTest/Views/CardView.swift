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
    @State private var distances: [String: String] = [:]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(Color(.systemGray6))
                .opacity(0.85)
            
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
                    cardState = .low
                    viewModel.searchQuery = ""
                    viewModel.searchResults = []
                })
                .padding(.top, 5)
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(viewModel.searchResults, id: \.self) { result in
                        
                        Button(action: {
                            
                        }) {
                            AddressView(result: result)
                        }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: screenHeight * 0.35, height: screenHeight * 0.001)
                    }
                }
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.clear)
                    .frame(height: screenHeight / 14)
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .cornerRadius(20)
    }
}

import MapKit
struct AddressView: View {
    
    var result: MKLocalSearchCompletion
    
    var body: some View {
        HStack{
            Image(systemName: "mappin.square.fill")
                .font(.system(size: 35))
                .foregroundColor(.red)
                .padding(.leading)
            
            VStack {
                HStack {
                    
                    Text("\(result.title)")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.bottom, -3)
                
                HStack {
                    
                    Text("20 km")
                        .font(.system(size: 13))
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: screenHeight * 0.007, height: screenHeight * 0.007)

                    Text("\(result.subtitle)")
                        .font(.system(size: 13))
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }.padding(.top, -3)
            }
            Spacer()
        }
        .frame(height: screenHeight / 15)
    }
}
