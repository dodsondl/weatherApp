//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "51d1b70c288592684886d1cf2e87021d"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                var weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
            }
            else {
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        
        if json["main"]["temp"] != nil {
        
      let tempResults = json["main"]["temp"].doubleValue
        let conditionResults = json["weather"][0]["id"].intValue
        let cityResults = json["name"].stringValue
        let iconResults = json["weather"]["icon"].stringValue
        
            weatherDataModel.temperature = Int(((tempResults - 273.15)*(9/5))+32)
            weatherDataModel.condition = conditionResults
            weatherDataModel.city = cityResults
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        
        else {
            print("invalid code")
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print(" \(location.coordinate.latitude) + \(location.coordinate.longitude)" )
            
            var latitude = String(location.coordinate.latitude)
            var longitude = String(location.coordinate.longitude)
        
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appID": APP_ID ]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredAnewCityName(city: String) {
        print(city)
        let newCityParams: [String: String] = ["q": city, "appID": APP_ID ]
        
        getWeatherData(url: WEATHER_URL, parameters: newCityParams)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
}


