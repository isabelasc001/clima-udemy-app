//
//  WeatherManager.swift
//  Clima
//
//  Created by Isabela Da Silva Cardoso on 26/03/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=e1e0e66e879d7a442f35ae0775df6de1&units=metric"
    
    func fetchWeather(cityName: String) {
        let urlStringName = "\(weatherURL)&q=\(cityName)"
        print(urlStringName)
        performRequest(with: urlStringName)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //create the URL
        if let newURL = URL(string: urlString) {
            //start a URLSession
            let urlSession = URLSession(configuration: .default)
            //give the session a task
            let urlTask = urlSession.dataTask(with: newURL) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
                urlTask.resume()
            }
        }
        
        func parseJSON(weatherData: Data) -> WeatherModel? {
            let decoder =  JSONDecoder()
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let temp = decodedData.main.temp
                let name =  decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
            
            
        }
    }

