//
//  TestResultView.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-06.
//

import SwiftUI

struct TestResultView: View {
    
    var numCorrect:Int
    
    @EnvironmentObject var model: ContentModel
    
    var resultHeading: String {
        
        guard model.currentModule != nil else {
            return ""
        }
        
        let percent = Double(numCorrect) / Double(model.currentModule!.test.questions.count)
        
        if percent > 0.5 {
            return "Awesome"
        } else if percent > 0.2 {
            return "Doing great!"
        } else {
            return "Keep learning"
        }
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text(resultHeading)
                .font(.title)
                .padding(.bottom)
            
            Text("You got \(numCorrect) out of \(model.currentModule?.test.questions.count ?? 0) questions")
            
            Spacer()
            
            Button(action: {
                
                // Send the user back to the HomeView
                model.currentTestSelected = nil
                
            }, label: {
                
                ZStack {
                    RectangleCard(color: Color.green)
                        .frame(height: 48)
                    Text("Complete")
                        .bold()
                        .foregroundColor(Color.white)
                }
            })
            .padding()
            
            Spacer()
        }
    }
}

//struct TestResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestResultView(model: ContentModel)
//            .environmentObject(ContentModel())
//    }
//}
