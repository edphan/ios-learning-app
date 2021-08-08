//
//  ContentModel.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-03.
//

import Foundation

class ContentModel: ObservableObject {
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current Model
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current Lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current Question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
   
    // Current lesson explanation
    @Published var codeText = NSAttributedString()
    
    // Current selected content and test
    @Published var currentContentSelected: Int?
    @Published var currentTestSelected: Int?
    
    var styleData: Data?
    
    init() {
        
        // Parse the included json data
        getLocalData()
        
        // download the remote json file and parse data
        getRemoteData()
        
    }
    
    // MARK: - data method
    
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
    
    func getRemoteData() {
        
        // String path
        let urlString = "https://edphan.github.io/learningapp-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // couldn't create url
            return
        }
        
        // create a URLRequest Object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            // Check if there is an error
            guard error == nil else {
                // There was an error
                return
            }
            
            // Handle the response
            // Create JSONDecoder
            let decoder = JSONDecoder()
            
            // Decode
            
            do {
                let modules = try decoder.decode([Module].self, from: data!)
                
                // Append parsed modules to modules array
                self.modules += modules
                
            } catch {
                print(error)
            }
            
            
        }
        
        // Kick off dataTask
        dataTask.resume()
        
    }
    
    // MARK: - Module navigation method
    
    func beginModule(_ moduleId: Int) {
        
        // Find the index of module id
        for index in 0..<modules.count {
            if modules[index].id == moduleId {
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    func beginLesson(_ lessonIndex: Int) {
        
        // Check the lesson index is within range of module's lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        } else {
            currentLessonIndex = 0
        }
        
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func nextLesson() {
        
        // Advance to the next lesson index
        currentLessonIndex += 1
        
        // Check if within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
            
        } else {
            
            // Reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
        }
    }
    
    func hasNextLesson() -> Bool {
        return currentLessonIndex + 1 < currentModule!.content.lessons.count
    }
    
    func beginTest(_ moduleId: Int) {
        
        // Set the current module
        beginModule(moduleId)
        
        // Set the current question
        currentQuestionIndex = 0
        
        // If there are questions, set the current question to the first question
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            
            // set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func nextQuestion() {
        
        // Advance to the next question index
        currentQuestionIndex += 1
        
        // Check if within range
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // Set the current question property
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
            
        } else {
            
            // Reset the lesson state
            currentQuestionIndex = 0
            currentQuestion = nil
        }
    }
    
    // MARK: - Code Styling
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        // Add the styling data
        if styleData != nil {
            data.append(self.styleData!)
        }
        
        // Add the html data
        data.append(Data(htmlString.utf8))
        
        // Convert to attributed string
        // if an error is thrown, the code inside the {} wont execute, it just skips the code in {}
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            resultString = attributedString
        }
        
        return resultString
    }
}
