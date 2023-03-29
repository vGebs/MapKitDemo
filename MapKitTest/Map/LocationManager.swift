//
//  LocationManager.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-29.
//

import Foundation
import CoreLocation

class LocationManagerWrapper: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var onLocationUpdated: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestUserLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        onLocationUpdated = completion
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdated?(.success(location.coordinate))
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onLocationUpdated?(.failure(error))
    }
}
