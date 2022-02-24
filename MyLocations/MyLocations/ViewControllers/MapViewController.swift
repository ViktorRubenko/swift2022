//
//  MapViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class MapViewController: UIViewController, ManagedObjectContextProtocol {
    
    var managedObjectContext: NSManagedObjectContext!
    var mapView: MKMapView!
    var locations: [Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Map"
        
        mapView = MKMapView(frame: .zero)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        
        setupConstraints()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "User",
            style: .plain,
            target: self,
            action: #selector(showUserLocation)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Locations",
            style: .plain,
            target: self,
            action: #selector(showLocations)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }
}

//MARK: - Helper Methods
extension MapViewController {
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func performFetch() {
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        locations = try! managedObjectContext.fetch(fetchRequest)
    }
    
    func updateLocations() {
        performFetch()
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
            var botRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                botRight.latitude = min(botRight.latitude, annotation.coordinate.latitude)
                botRight.longitude = max(botRight.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeft.latitude - botRight.latitude / 2,
                longitude: topLeft.longitude - botRight.longitude / 2)
            region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: abs(topLeft.latitude - botRight.latitude) * 1.1,
                    longitudeDelta: abs(topLeft.longitude - topLeft.longitude) * 1.1
                )
            )
        }
        return region
    }
}
//MARK: - Actions
extension MapViewController {
    @objc func showUserLocation() {
        let coordinate = mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @objc func showLocations() {
        mapView.addAnnotations(locations)
        mapView.setRegion(mapView.regionThatFits(region(for: locations)), animated: true)
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
        let index = sender.tag
        let location = locations[index]
        let controller = LocationDetailsViewController()
        controller.managedObjectContext = managedObjectContext
        controller.locationToEdit = location
        navigationController?.pushViewController(controller, animated: true)
    }
}
//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print(annotation is Location)
        guard annotation is Location else { return nil }
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            markerView.isEnabled = true
            markerView.canShowCallout = true
            markerView.markerTintColor = .green
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            markerView.rightCalloutAccessoryView = rightButton
            
            annotationView = markerView
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
