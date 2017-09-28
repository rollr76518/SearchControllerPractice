//
//  ViewController.swift
//  SearchControllerPractice
//
//  Created by Ryan on 2016/12/5.
//  Copyright © 2016年 Hanyu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "搜尋位置"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

        self.setupButtonLocateDevice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtonLocateDevice() {
        
        let buttonLocateDevice = MKUserTrackingBarButtonItem.init(mapView: mapView)
        buttonLocateDevice.customView?.tintColor = UIColor.orange
        buttonLocateDevice.customView?.backgroundColor = UIColor.white
        buttonLocateDevice.customView?.layer.cornerRadius = 3.0
        buttonLocateDevice.customView?.layer.masksToBounds = true
        
        let flexible = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        self.toolbar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.toolbar.setItems([flexible, buttonLocateDevice], animated: true)
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        pinView?.isDraggable = true
		pinView?.leftCalloutAccessoryView = UIButton.init(type: .detailDisclosure)//Should change to Navigation icon
        return pinView
    }

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if let annotation = view.annotation {
			showRoute(destination: annotation.coordinate)
		}
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = .orange
		renderer.lineWidth = 4.0
		return renderer
	}
	
	func showRoute(destination coordinate:CLLocationCoordinate2D) {
		let userMark = MKPlacemark.init(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
		let destinationMark = MKPlacemark.init(coordinate: coordinate, addressDictionary: nil)
		
		let userItem = MKMapItem.init(placemark: userMark)
		let destinationItem = MKMapItem.init(placemark: destinationMark)
		
		let request = MKDirectionsRequest.init()
		request.source = userItem
		request.destination = destinationItem
		request.transportType = .automobile
		
		let directions = MKDirections.init(request: request)
		directions.calculate { (response, error) in
			if let response = response, let route = response.routes.first {
				self.mapView.add(route.polyline, level: .aboveRoads)
				
				let rect = route.polyline.boundingMapRect
				self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
			}
			
			if let error = error {
				print(error)
			}
		}
	}
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = AddressTransformer().parseAddress(selectedItem: placemark)
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)

        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
