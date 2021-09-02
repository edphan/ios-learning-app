//
//  ContentModel.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-03.
//

import Foundation
import Firebase

class ContentModel: ObservableObject {
    
    let db = Firestore.firestore()
    
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
        
        // Parse the local style.html
        getLocalStyle()
        
        // download the remote json file and parse data
        // getRemoteData()
        
        // Get database modules
        getModules()
        
    }
    
    // MARK: - data method
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var lessons = [Lesson]()
                
                // Loop through the snapshot documents array and build the array of lessons
                for doc in snapshot!.documents {
                    
                    var l = Lesson()
                    
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add the lessons to the array
                    lessons.append(l)
                }
                
                // Setting the lessons to the module
                // Loop through the published modules array and find the one module that matches the id of the one that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // Find the module we want
                    if m.id == module.id {
                        
                        // set the lesson
                        self.modules[index].content.lessons = lessons
                        
                        // Call the completion closure
                        completion()
                    }
                }
            }
        }
    }
    
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        // Get documents
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var questions = [Question]()
                
                // Loop through the snapshot documents array and build the array of lessons
                for doc in snapshot!.documents {
                    
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    // Add the lessons to the array
                    questions.append(q)
                }
                
                // Setting the lessons to the module
                // Loop through the published modules array and find the one module that matches the id of the one that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // Find the module we want
                    if m.id == module.id {
                        
                        // set the lesson
                        self.modules[index].test.questions = questions
                        
                        // Call the completion closure
                        completion()
                    }
                }
            }
        }
    }
    
    func getModules() {
        
        // Specify path
        let collection = db.collection("modules")
        
        // Get document
        collection.getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                
                // Create an array for the modules
                var modulesArray = [Module]()
                
                // Loop through the returned document
                for doc in snapshot!.documents {
                    
                    // Create a new module instance
                    var m = Module()
                    
                    // Parse out the value from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // Parse the lesson content
                    let contentMap = doc["content"] as! [String: Any]
                    
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // Parse the test content
                    let testMap = doc["test"] as! [String: Any]
                    
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add to array
                    modulesArray.append(m)
                }
                
                // Assign the modules to the published property
                DispatchQueue.main.async {
                    self.modules = modulesArray
                }
            }
        }
    }
    
    func getLocalStyle() {
        /*
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
        */
        
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
                
                // When possible, assign to the main thread, leaving background thread free to update UI
                DispatchQueue.main.async {
                    // Append parsed modules to modules array
                    self.modules += modules
                }
                
            } catch {
                print(error)
            }
            
            
        }
        
        // Kick off dataTask
        dataTask.resume()
        
    }
    
    // MARK: - Module navigation method
    
    func beginModule(_ moduleId: String) {
        
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
        
        guard currentModule != nil else {
            return false
        }
        
        return currentLessonIndex + 1 < currentModule!.content.lessons.count
    }
    
    func beginTest(_ moduleId: String) {
        
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
