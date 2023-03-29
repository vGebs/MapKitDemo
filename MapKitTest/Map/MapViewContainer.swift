//
//  MapViewContainer.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-28.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapViewContainer: View {
    @StateObject private var viewModel: MapViewModel
    
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
            
            VStack {
//                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(.black)
                        .opacity(0.75)
                    
                    VStack {
                        
                        SearchBar(text: $viewModel.searchQuery, onEdit: { newVal in
                            viewModel.updateSearchQuery(query: newVal)
                        })
                        .padding(.top)
                        .padding(.horizontal)
                        
                        List(viewModel.searchResults, id: \.self) { result in
                            Button(action: {
                                viewModel.search(query: result.title)
                            }) {
                                Text(result.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .frame(width: 300, height: 300)
            .padding()
        }
    }
}
