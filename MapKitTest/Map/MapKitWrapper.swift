//
//  MapKitWrapper.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-28.
//

import Foundation
import MapKit
import CoreLocation

class MapKitWrapper {
    
    // Location search
    func searchLocation(query: String, completion: @escaping (Result<[MKMapItem], Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let mapItems = response?.mapItems {
                completion(.success(mapItems))
            }
        }
    }

    // Routing
    func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, via transportType: MKDirectionsTransportType, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let route = response?.routes.first {
                completion(.success(route))
            }
        }
    }

    func estimateTravelTime(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType, completion: @escaping (Result<TimeInterval, Error>) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = transportType

        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let eta = response?.expectedTravelTime {
                completion(.success(eta))
            }
        }
    }
    
    //Convert an address or place name into geographic coordinates.
    func geocode(address: String, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
            } else if let placemark = placemarks?.first {
                completion(.success(placemark))
            }
        }
    }
    
    //Convert a geographic coordinate to address or place name
    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
            } else if let placemark = placemarks?.first {
                completion(.success(placemark))
            }
        }
    }
    
    //Find points of interest for coordinate
    func findNearbyPOIs(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, categories: [MKPointOfInterestCategory], completion: @escaping (Result<[MKMapItem], Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let mapItems = response?.mapItems {
                completion(.success(mapItems))
            }
        }
    }
    
    //Create a route that includes several stops along the way.
    func calculateRouteWithWaypoints(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], transportType: MKDirectionsTransportType, completion: @escaping (Result<[MKRoute], Error>) -> Void) {
        let allCoordinates = [source] + waypoints + [destination]
        var routes: [MKRoute] = []

        let group = DispatchGroup()

        for index in 0..<(allCoordinates.count - 1) {
            group.enter()

            self.calculateRoute(from: allCoordinates[index], to: allCoordinates[index + 1], via: transportType) { result in
                switch result {
                case .success(let route):
                    routes.append(route)
                    group.leave()
                case .failure(let error):
                    completion(.failure(error))
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(routes))
        }
    }
}

extension MapKitWrapper {
    func calculateDrivingRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        calculateRoute(from: source, to: destination, via: .automobile, completion: completion)
    }
    
    func calculateWalkingRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        calculateRoute(from: source, to: destination, via: .walking, completion: completion)
    }

    func calculateTransitRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, Error>) -> Void) {
        calculateRoute(from: source, to: destination, via: .transit, completion: completion)
    }
}
