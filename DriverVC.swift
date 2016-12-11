//
//  DriverVC.swift
//  VIRA-Driver
//
//  Created by Steve Sneller on 12/5/16.
//  Copyright © 2016 SteveSneller. All rights reserved.
//

import UIKit
import MapKit


class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {   //, ViraController
    
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var acceptViraBtn: UIButton!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var riderLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    
    private var acceptedVira = false;
    private var driverCanceledVira = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager();
        
  //              ViraHandler.Instance.delegate = self;
 //               ViraHandler.Instance.observeMessagesForDriver();
        
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            myMap.setRegion(region, animated: true);
            
            myMap.removeAnnotations(myMap.annotations);
            
            if riderLocation != nil {
                if acceptedVira {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = riderLocation!;
                    riderAnnotation.title = "Riders Location";
                    myMap.addAnnotation(riderAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            myMap.addAnnotation(annotation);
            
        }
        
    }
    
    func acceptVira(lat: Double, long: Double) {
        if !acceptedVira {
            //            ViraRequest(title: "Vira Request", message: "You have a request for an Vira at this location Lat: \(lat), Long: \(long)", requestAlive: true);
        }
    }
    
    func riderCanceledVira() {
        if !driverCanceledVira {
            //            ViraHandler.Instance.cancelViraForDriver();
            self.acceptedVira = false;
            self.acceptViraBtn.isHidden = true;
            viraRequest(title: "Vira Canceled", message: "The Rider Has Canceled The Vira", requestAlive: false);
        }
    }
    
    func viraCanceled() {
        acceptedVira = false;
        acceptViraBtn.isHidden = true;
        timer.invalidate();
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateDriversLocation() {
        //        ViraHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    @IBAction func cancelVira(_ sender: AnyObject) {
        if acceptedVira {
            driverCanceledVira = true;
            acceptViraBtn.isHidden = true;
            //            ViraHandler.Instance.cancelViraForDriver();
            timer.invalidate();
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            
            if acceptedVira {
                acceptViraBtn.isHidden = true;
                //                ViraHandler.Instance.cancelViraForDriver();
                timer.invalidate();
            }
            
            dismiss(animated: true, completion: nil);
            
        } else {
            // problem with logging out
            viraRequest(title: "Could Not Logout", message: "We could not logout at the moment, please try again later", requestAlive: false)
        }
    }
    
    private func viraRequest(title: String, message: String, requestAlive: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedVira = true;
                self.acceptViraBtn.isHidden = false;
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true);
                
                //                ViraHandler.Instance.viraAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude));
                
            });
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            
            alert.addAction(accept);
            alert.addAction(cancel);
            
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(ok);
        }
        
        present(alert, animated: true, completion: nil);
    }
    
} // class


















