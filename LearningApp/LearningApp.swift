//
//  LearningApp.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-03.
//

import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(ContentModel())
        }
    }
}
