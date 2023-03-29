//
//  MapViewModel.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-28.
//

import Foundation
import MapKit
import CoreLocation
import Combine

class MapViewModel: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MKAnnotation]
    @Published var overlays: [MKOverlay]
    @Published var mapType: MKMapType
    
    var onAnnotationSelected: ((MKAnnotation) -> Void)?

    @Published var mapItems: [MKMapItem] = []
    @Published var route: MKRoute?
    @Published var travelTime: TimeInterval?
    @Published var placemark: CLPlacemark?
    @Published var nearbyPOIs: [MKMapItem] = []
    @Published var multiStopRoutes: [MKRoute] = []
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private var mapKitWrapper = MapKitWrapper()
    private var searchCompleter: MKLocalSearchCompleter
    private var locationManagerWrapper = LocationManagerWrapper()
    
    private var cancellables = Set<AnyCancellable>()

    init(region: MKCoordinateRegion,
         annotations: [MKAnnotation] = [],
         overlays: [MKOverlay] = [],
         mapType: MKMapType = .standard,
         onAnnotationSelected: ((MKAnnotation) -> Void)? = nil) {
        
        self.region = region
        self.annotations = annotations
        self.overlays = overlays
        self.mapType = mapType
        self.onAnnotationSelected = onAnnotationSelected
        self.searchCompleter = MKLocalSearchCompleter()
        super.init()
        
        searchCompleter.delegate = self
        
        locationManagerWrapper.requestUserLocation { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coordinate):
                    self?.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                case .failure(let error):
                    print("Error updating location: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateSearchQuery(query: String) {
        searchQuery = query
        searchCompleter.queryFragment = query
    }
    
    func search(query: String) {
        print("Query: \(query)")
        mapKitWrapper.searchLocation(query: query) { [weak self] result in
            switch result {
            case .success(let mapItems):
                self?.mapItems = mapItems
            case .failure(let e):
                print("MapViewModel: Failed to search location")
                print("MapViewModel-Error: \(e)")
            }
        }
    }
}

extension MapViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }

    func searchCompleter(_ completer: MKLocalSearchCompleter, didUpdateCompletions completions: [MKLocalSearchCompletion]) {
        DispatchQueue.main.async {
            self.searchResults = completions
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching search results: \(error)")
    }
}
