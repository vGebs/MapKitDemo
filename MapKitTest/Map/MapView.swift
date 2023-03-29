//
//  MapView.swift
//  MapKitTest
//
//  Created by Vaughn on 2023-03-28.
//

import MapKit
import Combine
import SwiftUI

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    var showsUserLocation: Bool
    var minZoomLevel: Double
    var maxZoomLevel: Double

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(viewModel.region, animated: true)
        uiView.showsUserLocation = showsUserLocation
        uiView.addOverlays(viewModel.overlays)
        uiView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: minZoomLevel, maxCenterCoordinateDistance: maxZoomLevel)
        uiView.mapType = viewModel.mapType
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: MapViewModel

        init(_ viewModel: MapViewModel) {
            self.viewModel = viewModel
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                viewModel.onAnnotationSelected?(annotation)
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

