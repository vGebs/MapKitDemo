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
    @Published var currentRegion: MKCoordinateRegion
    @Published var highlightedRegion: MKCoordinateRegion?
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
        
        self.currentRegion = region
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
                    self?.currentRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
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
        mapKitWrapper.searchLocation(query: query) { [weak self] result in
            switch result {
            case .success(let mapItems):
                self?.mapItems = mapItems
                for item in mapItems {
                    self?.highlightRegion(at: item.placemark.coordinate, withSpan: 100)
                }
            case .failure(let e):
                print("MapViewModel: Failed to search location")
                print("MapViewModel-Error: \(e)")
            }
        }
    }
    
    func highlightRegion(at coordinate: CLLocationCoordinate2D, withSpan span: CLLocationDegrees) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: span, longitudinalMeters: span)
        highlightedRegion = region
        addHighlightOverlay(for: coordinate)
    }
    
    func estimateTravel(to destination: String) -> String {
        let group = DispatchGroup()
        var travelTime: TimeInterval? = nil
        var destinationCoordinate: CLLocationCoordinate2D? = nil
        
        group.enter()
        mapKitWrapper.geocode(address: destination) { result in
            switch result {
            case .success(let placemark):
                destinationCoordinate = placemark.location?.coordinate
                group.leave()
            case .failure(let error):
                print("Geocoding error: \(error)")
                group.leave()
            }
        }
        
        group.wait()
        
        if let destinationCoordinate = destinationCoordinate {
            group.enter()
            mapKitWrapper.estimateTravelTime(from: currentRegion.center, to: destinationCoordinate, transportType: .automobile) { result in
                switch result {
                case .success(let timeInterval):
                    travelTime = timeInterval
                    group.leave()
                case .failure(let error):
                    print("Estimate travel time error: \(error)")
                    group.leave()
                }
            }
        } else {
            return "Not available"
        }
        
        group.wait()
        
        if let travelTime = travelTime {
            return convertTimeIntervalToString(travelTime)
        } else {
            return "Not available"
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

extension MapViewModel {
    private func addHighlightOverlay(for coordinate: CLLocationCoordinate2D) {
        let circle = MKCircle(center: coordinate, radius: 500)
        overlays.append(circle)
    }
}

extension MapViewModel {
    private func convertTimeIntervalToString(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: interval) ?? ""
    }
}
