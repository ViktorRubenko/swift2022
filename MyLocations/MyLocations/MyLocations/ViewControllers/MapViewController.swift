//
//  MapViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 21.02.2022.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, managedObjectContextProtocol {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()

    var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.addSubview(mapView)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Locations", style: .plain, target: self, action: #selector(showLocations)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "User", style: .plain, target: self, action: #selector(showUser)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc func showLocations() {
        mapView.setRegion(region(for: locations), animated: true)
    }

    @objc func showUser() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
        let controller = LocationDetailsViewController()
        controller.managedObjectContext = managedObjectContext
        controller.locationToEdit = locations[sender.tag]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helper Methods
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            region = MKCoordinateRegion(center: annotations[0].coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: (topLeft.longitude - bottomRight.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        return region
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else { return nil }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesWhenAdded = false
            pinView.tintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
    }
}
