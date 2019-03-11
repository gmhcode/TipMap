//
//  ViewController.swift
//  TipMap
//
//  Created by Greg Hughes on 3/10/19.
//  Copyright © 2019 Greg Hughes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    var previousLocation : CLLocation?
    let locationManager = CLLocationManager()
    let regionInMeters : Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    
    @IBAction func centerViewButtonTapped(_ sender: Any) {
        centerViewOnUserLocation()
    }
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate{
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
    }

    
    func getPinLocation(annotation: MKPointAnnotation)->CLLocation{
        
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
    func getCenterLocationFor(mapView:MKMapView)->CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        
        let locationCoordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoordinates
        //        print("🌸\(annotation.coordinate)")
        annotation.title = "New Place"
        annotation.subtitle = " subtitle"
        
        
        mapView.addAnnotation(annotation)
        previousLocation = getPinLocation(annotation: annotation)
    }
    
    
}

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation.title != "My Location" else {print("❇️♊️>>>\(#file) \(#line): guard let failed<<<"); return nil}
        #warning("this needs to guard against annotations being of a certain type which  i will make.")
        
        
        let identifier = "Marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            
            dequeuedView.annotation = annotation
            view = dequeuedView
            
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let latAndLong = view.annotation?.coordinate
        
        guard let coordinate = latAndLong else {print("❇️♊️>>>\(#file) \(#line): guard let failed<<<"); return}
        
//                previousLocation = getPinLocation(annotation: view.annotation as! MKPointAnnotation)
        
        let geoCoder = CLGeocoder()
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else {print("❇️♊️>>>\(#file) \(#line): guard let failed<<<"); return}
            
            
            if let error = error {
                print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription) : \(#file) \(#line)")
                return
            }
            guard let placemark = placemarks?.first else {print("❇️♊️>>>\(#file) \(#line): guard let failed<<<"); return}
//                        print("🔥🥶\(placemarks)")
//           Search Documentation for CLPlacemark
            let streetAddress = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetAddress), \(streetName)"
            }
        }
    }
    //allows user to see driving directions
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}



extension MapController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {print("❇️♊️>>>\(#file) \(#line): guard let failed<<<"); return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // uncommenting these will constantly center the screen on the users location.
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
        
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else {
            //            #warning("give user alert to let them know location services isnt working")
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            startTrackingUserLocation()
            break
        case .denied:
            //            #warning ("make alert showing how to turn on permissions")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
}


