//
//  ContentModel.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-03.
//

import Foundation
import Firebase
import FirebaseAuth

class ContentModel: ObservableObject {
    
    // Authentication
    @Published var loggedIn = false
    
    // Reference to Cloud Firestore database
    let db = Firestore.firestore()
    
    // List of modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    // Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current lesson explanation
    @Published var codeText = NSAttributedString()
    var styleData: Data?
    
    // Current selected content and test
    @Published var currentContentSelected:Int?
    @Published var currentTestSelected:Int?
    
    
    init() {
    }
    
    // MARK: - Authentication methods
    
    func checkLogin() {
        
        // Check if there's a current user to determine logged in status
        loggedIn = Auth.auth().currentUser != nil ? true : false
        
        // Check if user meta data has been fetched. If the user was already logged in from a previous sesson, we need to get their data in a separate call
        if UserService.shared.user.name == "" {
            getUserData()
        }
        
        // Check if user meta data has been fetched. If the user was already logged in from a previous session, we need to get their data in a separate call
        if UserService.shared.user.name == "" {
            getUserData()
        }
    }
    
    // MARK: - Data methods
    
    func saveData(_ writeToDatabase: Bool = false) {
        
        if let loggedInUser = Auth.auth().currentUser {
            // Save the progress data locally
           let user = UserService.shared.user
           user.lastModule = currentModuleIndex
           user.lastLesson = currentLessonIndex
           user.lastQuestion = currentQuestionIndex
           
            if writeToDatabase {
                // Save it to the db
                let db = Firestore.firestore()
                 let ref = db.collection("users").document(loggedInUser.uid)
                 ref.setData(["lastModule": user.lastModule ?? NSNull(),
                              "lastLesson": user.lastLesson ?? NSNull(),
                              "lastQuestion": user.lastQuestion ?? NSNull()], merge: true)
            }
           
        }
        
         
    }
    
    func getUserData() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // Get the meta data for that user
        let db = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { snapshot, error in
            
            // Check there's no errors
            guard error == nil, snapshot != nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.name = data?["name"] as? String ?? ""
            user.lastModule = data?["lastModule"] as? Int
            user.lastLesson = data?["lastLesson"] as? Int
            user.lastQuestion = data?["lastQuestion"] as? Int
        }
    }
    
    func getDatabaseData() {
        
        // Parse local included json data
        getLocalStyleData()
        
        // Get a reference to the modules collection
        let collection = db.collection("modules")
        
        // Get the documents for the collection
        collection.getDocuments { snapshot, error in
            if error == nil {
                
                // Declare temp module list
                var modules = [Module]()
                
                for doc in snapshot!.documents {
                    
                    var m = Module(id: doc["id"] as? String ?? "",
                                   category: doc["category"] as? String ?? ""
                                   )
                    m.content.id = doc["id"] as? String ?? ""
                    
                    // Content properties
                    let c = doc["content"] as! [String: Any]
                    
                    m.content.image = c["image"] as? String ?? ""
                    m.content.time = c["time"] as? String ?? ""
                    m.content.description = c["description"] as? String ?? ""
                    
                    // Test properties
                    let t = doc["test"] as! [String:Any]
                    
                    m.test.image = t["image"] as? String ?? ""
                    m.test.time = t["time"] as? String ?? ""
                    m.test.description = t["description"] as? String ?? ""
                    
                    modules.append(m)
                }
                
                DispatchQueue.main.async {
                    self.modules = modules
                }
            }
        }
        
    }
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // Get a reference to the collection for lessons
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get the documents from the collection
        collection.getDocuments { snapshot, error in
            if error == nil {
                
                var lessons = [Lesson]()
                
                for doc in snapshot!.documents {
                    
                    var q = Lesson()
                    //q.id = doc["id"] as? String ?? ""
                    q.duration = doc["duration"] as? String ?? ""
                    q.explanation = doc["explanation"] as? String ?? ""
                    q.title = doc["title"] as? String ?? ""
                    q.video = doc["video"] as? String ?? ""
                    
                    lessons.append(q)
                }
                
                for (index, m) in self.modules.enumerated() {
                    
                if module.id == m.id {
                        DispatchQueue.main.async {
                            self.modules[index].content.lessons = lessons
                           // self.currentModule?.content.lessons = lessons
                            completion()
                        }
                        break
                    }
                    
                }
                
                
            }
            
        }
    }
    
    func getQuestions(module: Module, completion: @escaping ()-> Void) {
        // Get a reference to the collection for questions
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        // Get the documents for the collection
        collection.getDocuments { snapshot, error in
            if error == nil {
                
                var questions = [Question]()
                
                for doc in snapshot!.documents {
                    
                    var q = Question()
                    //q.id = doc["id"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.content = doc["content"] as? String ?? ""
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    questions.append(q)
                }
                
                for (index, m) in self.modules.enumerated() {
                    
                if module.id == m.id {
                        DispatchQueue.main.async {
                            self.modules[index].test.questions = questions
                           // self.currentModule?.content.lessons = lessons
                            completion()
                        }
                        break
                    }
                    
                }
                
                
            }
            
        }
    }
    
    func updateModule<Element>(module: Module?, data: [Element]) {
        
        // Check that a module was given
        guard module != nil else {
            print("No module provided for child data.")
            return
        }
        
        // Find the module we want to update
        for (index, mod) in self.modules.enumerated() {
            
            if module!.id == mod.id {
                
                // We found the module, update the UI
                DispatchQueue.main.async {
                    
                    if let questions = data as? [Question] {
                        self.modules[index].test.questions = questions
                        
                    } else if let lessons = data as? [Lesson] {
                        self.modules[index].content.lessons = lessons
                        
                    }
                }
                
                break
            }
        }
    }
    
    func getLocalStyleData() {
        
        
        
        // Parse the style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            
            // Read the file into a data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
        }
        catch {
            // Log error
            print("Couldn't parse style data")
        }
        
    }
    
    func getRemoteData() {
        
        // String path
        let urlString = "https://codewithchris.github.io/learningapp-data/data2.json"
        
        // Create a url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // Couldn't create url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            // Check if there's an error
            guard error == nil else {
                // There was an error
                return
            }
            
            do {
                // Create json decoder
                let decoder = JSONDecoder()
            
                // Decode
                let modules = try decoder.decode([Module].self, from: data!)
                
                DispatchQueue.main.async {
                    
                    // Append parsed modules into modules property
                    self.modules += modules
                }
                
            }
            catch {
                // Couldn't parse json
            }
        }
        
        // Kick off data task
        dataTask.resume()
        
    }
    
    // MARK: - Module navigation methods
    
    func beginModule(_ moduleid:String) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            
            if modules[index].id == moduleid {
            
                // Found the matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    func beginLesson(_ lessonIndex:Int) {
        
        // Reset the question index
        currentQuestionIndex = 0
        
        // Check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // Set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func nextLesson() {
        
        // Advance the lesson index
        currentLessonIndex += 1
        
        // Check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // Set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        }
        else {
            // Reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
        }
        
        // Save the progress
        saveData()
    }
    
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func beginTest(_ moduleId:String) {
        
        // Set the current module
        beginModule(moduleId)
        
        // Set the current question index
        currentQuestionIndex = 0
        
        // Reset the lesson index
        currentLessonIndex = 0
        
        // If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0  > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            
            // Set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func nextQuestion() {
        
        // Advance the question index
        currentQuestionIndex += 1
        
        // Check that it's within the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // Set the current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        }
        else {
            // If not, then reset the properties
            currentQuestionIndex = 0
            currentQuestion = nil
        }
        
        saveData()
        
    }
    
    // MARK: - Code Styling
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        // Add the styling data
        if styleData != nil {
            data.append(styleData!)
        }
        
        // Add the html data
        data.append(Data(htmlString.utf8))
        
        // Convert to attributed string
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            resultString = attributedString
        }
        
        return resultString
    }
}
