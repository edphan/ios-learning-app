//
//  ContentModel.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-03.
//

import Foundation

class ContentModel: ObservableObject {
    
    @Published var modules = [Module]()
    var styleData: Data?
    
    init() {
        getLocalData()
    }
    
    func getLocalData() {
        // Get URL to JSON file
        let jsonURL = Bundle.main.url(forResource: "data", withExtension: "json")
        
        // Read the file into data object
        do {
            
            let jsonData = try Data(contentsOf: jsonURL!)
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let parsedModules = try jsonDecoder.decode([Module].self, from: jsonData)
                
                // Assign parsed modules to modules property
                self.modules = parsedModules
                
            } catch {
                // prints error when trying to decode
                print(error)
            }
            
        } catch {
            // prints error when trying to read file into data object
            print(error)
        }
        
        // Parse the style data
        let styleURL = Bundle.main.url(forResource: "style", withExtension: "html")
        
        // Read the file into data object
        do {
            
            // Read the file into data object
            let styleData = try Data(contentsOf: styleURL!)
            
            self.styleData = styleData
            
        } catch {
            print("Couldnt parse style data")
        }
        
    }
}
