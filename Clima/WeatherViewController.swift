//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON


class WeatherViewController: UIViewController {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    
    //TODO: Declare instance variables here
    var manager:CLLocationManager!
    var managerDelegate: CLLocationManagerDelegate!
    var lat: Double = 0.0
    var lon: Double = 0.0

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        manager = CLLocationManager()
        managerDelegate = manager.delegate
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = locValue.latitude
        lon = locValue.longitude
        getWeatherData()
        
    
        
        
    }
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(){
        
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&APPID=\(APP_ID)"
        AF.request(url).responseJSON { response in
            guard let data = response.data else {
                
                return
            }
            
            let json = try? JSON(data: data)
            
            
            guard  let results = json else {
               print("vacio")
                return
            }
            self.updateWeatherData(data:results)
            
        }
        
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(data: JSON){
        guard let temp: Double = data["main"]["temp"].double, let city = data["name"].string, let condition = data["weather"][0]["id"].int else{
            
            
            return
        }
        let celsius = temp - 273.1
        self.updateUIWithWeatherData(temp:celsius,city:city,condition: condition)
        
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(temp: Double, city: String, condition: Int){
        self.cityLabel.text = city
        self.temperatureLabel.text = String(Int(temp)) + "º"
        print(String(temp) + "º")
        self.weatherIcon.image = UIImage.init(named:WeatherDataModel().updateWeatherIcon(condition: condition))
        
        
    
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]){
        self.getWeatherData()
        
        
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
        manager.stopUpdatingLocation()
        self.cityLabel.text = error.localizedDescription
        self.temperatureLabel.text = ""
        self.weatherIcon.image = UIImage()
        
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let destinationController = segue.destination as? ChangeCityViewController {
            destinationController.delegate = self
            
            
        }
    }
    
    
    
    
    
    
}
extension WeatherViewController: CityChangeDelegate{
    func changeCity(city: String) {
        let url = "http://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=\(APP_ID)"
        print(url)
        AF.request(url).responseJSON { response in
            guard let data = response.data else {
                
                return
            }
            
            let json = try? JSON(data: data)
            
            
            guard  let results = json else {
                print("vacio")
                return
                
            }
            if(results["cod"].int != 200){
                self.weatherIcon.image = UIImage()
                self.cityLabel.text = "Error while loading, try again"
                self.temperatureLabel.text = ""
            }else{
                self.updateWeatherData(data:results)
            }
           
            
        }
        
    }
    
}


