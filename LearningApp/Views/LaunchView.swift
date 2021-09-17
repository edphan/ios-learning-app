//
//  LaunchView.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-09-14.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    
    var body: some View {
        
        if !model.loggedIn {
            // show login view
            LoginView()
                .onAppear {
                    // Check if the user is logged in or out
                    model.checkLogin()
                }
            
        } else {
            //show logged in view
            TabView {
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book")
                            Text("Learn")
                        }
                    }
                
                ProfileView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("Learn")
                        }
                    }
            }
            .onAppear {
                model.getDatabaseData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
                
                // Save progress to the db when the app is moving from active to background
                model.saveData(true)
            })
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
