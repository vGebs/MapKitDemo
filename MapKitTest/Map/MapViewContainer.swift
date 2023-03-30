//
//  MapViewContainer.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-28.
//

import SwiftUI
import MapKit
import CoreLocation

let screenHeight = UIScreen.main.bounds.height

struct MapViewContainer: View {
    @StateObject private var viewModel: MapViewModel
    @State private var cardState: SwipeableCardView<CardView>.CardState = .low // Add this line

    init() {
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        _viewModel = StateObject(wrappedValue: MapViewModel(region: initialRegion))
    }
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel, showsUserLocation: true, minZoomLevel: 500, maxZoomLevel: 100000000)
                .edgesIgnoringSafeArea(.all)
            
            SwipeableCardView(maxHeight: screenHeight, cardState: $cardState) {
                CardView(viewModel: viewModel, cardState: $cardState)
            }
        }
    }
}
