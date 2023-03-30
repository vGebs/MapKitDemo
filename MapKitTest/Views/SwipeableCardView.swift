//
//  SwipeableCardView.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-29.
//

import SwiftUI

struct SwipeableCardView<Content: View>: View {
    @GestureState private var dragOffset: CGFloat = 0
    @Binding private var cardState: CardState
    
    let content: Content
    let maxHeight: CGFloat
    
    init(maxHeight: CGFloat, cardState: Binding<CardState>, @ViewBuilder content: () -> Content) {
        self._cardState = cardState
        self.content = content()
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            .offset(y: cardOffset(for: cardState, height: maxHeight) + dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let offsetThreshold: CGFloat = maxHeight * 0.15
                        let midThreshold: CGFloat = maxHeight * 0.3

                        if value.translation.height > offsetThreshold {
                            if cardState == .high {
                                cardState = .mid
                            } else if cardState == .mid {
                                cardState = .low
                            }
                        } else if value.translation.height > midThreshold {
                            if cardState == .high {
                                cardState = .low
                            }
                        } else if value.translation.height < -offsetThreshold {
                            if cardState == .low {
                                cardState = .mid
                            } else if cardState == .mid {
                                cardState = .high
                            }
                        } else if value.translation.height < -midThreshold {
                            if cardState == .low {
                                cardState = .high
                            }
                        }
                    }
            )
            .animation(.spring(), value: cardState)
    }
    
    enum CardState {
        case low
        case mid
        case high
    }
    
    func cardOffset(for state: CardState, height: CGFloat) -> CGFloat {
        switch state {
        case .low:
            return height * 0.81
        case .mid:
            return height * 0.5
        case .high:
            return height * 0.10
        }
    }
}
