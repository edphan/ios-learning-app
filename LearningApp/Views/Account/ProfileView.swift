//
//  ProfileView.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-09-14.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var model: ContentModel
    var body: some View {
        Button(action: {
            // Sign out the user
            try! Auth.auth().signOut()
            
            // Change to logged out view
            model.checkLogin()
            
        }, label: {
            Text("Sign Out")
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
