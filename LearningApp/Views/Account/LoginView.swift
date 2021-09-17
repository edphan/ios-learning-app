//
//  LoginView.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-09-14.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct LoginView: View {
    
    @EnvironmentObject var model: ContentModel
    @State var loginMode = Constants.loginMode.login
    @State var email = ""
    @State var name = ""
    @State var password = ""
    @State var errorMessage: String? = nil
    
    var buttonText: String {
        if loginMode == Constants.loginMode.login {
            return "Login"
        } else {
            return "Sign Up"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            Spacer()
            // Logo
            Image(systemName: "book")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 150)
            
            // Title
            Text("Learnzilla")
            
            Spacer()
            
            // Picker
            Picker(selection: $loginMode, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/, content: {
                Text("Login")
                    .tag(Constants.loginMode.login)
                
                Text("Sign Up")
                    .tag(Constants.loginMode.createAccount)
            })
            .pickerStyle(SegmentedPickerStyle())
            
            Group {
                // Form
                TextField("Email", text: $email)
                
                if loginMode == Constants.loginMode.createAccount {
                    TextField("Name", text: $name)
                }
                
                SecureField("Password", text: $password)
                
                if errorMessage != nil {
                    Text(errorMessage!)
                }
            }
            
            // Button
            Button(action: {
                
                if loginMode == Constants.loginMode.login {
                    
                    // Log the user in
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        
                        // Check for errors
                        guard error == nil else {
                            errorMessage = error!.localizedDescription
                            return
                        }
                        
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Fetch user metadata
                        model.getUserData()
                        
                        // Change the view to logged in view
                        model.checkLogin()
                        
                    }
                } else {
                    // Create new account
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        
                        // Check for errors
                        guard error == nil else {
                            errorMessage = error!.localizedDescription
                            return
                        }
                        
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Save the first name
                        let firebaseUser = Auth.auth().currentUser
                        let db = Firestore.firestore()
                        let ref = db.collection("users").document(firebaseUser!.uid)
                        ref.setData(["name": name], merge: true)
                        
                        // Update the user meta data
                        let user = UserService.shared.user
                        user.name = name
                        
                        // Change the view to logged in view
                        model.checkLogin()
                    }
                }
            }, label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: 40)
                        .cornerRadius(10)
                    
                    Text(buttonText)
                        .foregroundColor(.white)
                }
            })
            
            Spacer()
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal, 40)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
