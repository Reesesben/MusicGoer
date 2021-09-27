//
//  LocationViewController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation

class LocationViewController: UIViewController, searchViewControllerDelegate {
    
    //MARK: - PROPERITES
    
    let manager = CLLocationManager()
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    var event: Event?
    
    //MARK: - LIFECYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        
        let searchVC = SearchViewController()
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        setupViews()
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    //MARK: - HELPER FUNCTIONS
    
    func setupViews() {
        // Set accuracy for location
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // set delegate for location
        manager.delegate = self
        // Request permission
        manager.requestWhenInUseAuthorization()
        // Fetch location
        manager.startUpdatingLocation()
        // Set delegate for mapView
        mapView.delegate = self
    }
    
    //MARK: - PERMISSIONS
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) -> Bool {
        var hasPermission = false
        switch manager.authorizationStatus {
        // App first launched, hasn't determined
        case .notDetermined:
            // For use when the app is open
            manager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            hasPermission = true
            break
        // For use when the app is open
        case .authorizedWhenInUse:
            hasPermission = true
            break
        @unknown default:
            break
        }
        
        switch manager.accuracyAuthorization {
        
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            break
        @unknown default:
            break
        }
        // This will update us along the way, as the user has our app
        manager.startUpdatingLocation()
        return hasPermission
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Status is the outcome of our ability to use their location, where were checking if there's been changes
        switch status {
        case .restricted:
            print("\nUsers location is restricted")
            
        case .denied:
            print("\nUser denied access to use their location\n")
            
        case .authorizedWhenInUse:
            print("\nuser granted authorizedWhenInUse\n")
            
        case .authorizedAlways:
            print("\nuser selected authorizedAlways\n")
            
        default: break
        }
    }
    
    //MARK: - ACTIONS
    
    @objc func saveTapped() {
        guard let event = event else { return }
        event.latitude = LocationManager.shared.location.last?.coordinates.latitude ?? 0.0
        event.longitude = LocationManager.shared.location.last?.coordinates.longitude ?? 0.0
    }
    
    func searchViewController(_ vc: SearchViewController, didSelectLocaitonWith coordinates: CLLocationCoordinate2D?) {
        
        guard let coordinates = coordinates else { return }
        
        panel.move(to: .tip, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.title = LocationManager.shared.location.last?.title
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
    }
} // End of Class

extension LocationViewController: MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    // Delegate function; gets called when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let event = event else { return }
        if event.latitude != 0.0 && event.longitude != 0.0 {
            if let location = locations.first {
                manager.stopUpdatingLocation()
                render(location)
            }
        } else {
            var savedLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            render(savedLocation)
        }
    }
    
    // Zoom into map on location, & add pin
    func render(_ location: CLLocation) {
        // The latitude and longitude associated with a location
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        // The width and height of a map region.
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        // Set maps region(view)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    // Set custom image for map pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        annotationView.image = UIImage(named: "plopdog")
        annotationView.canShowCallout = true
        annotationView.calloutOffset = CGPoint(x: -5, y: 5)
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
} // End of Extension
