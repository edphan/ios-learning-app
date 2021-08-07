//
//  TestView.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-08-06.
//

import SwiftUI

struct TestView: View {
    
    @EnvironmentObject var model: ContentModel
    @State var selectedAnswerIndex: Int?
    @State var numCorrect = 0
    @State var submitted = false
    @State var showResult = false
    
    var body: some View {
        
        if model.currentQuestion != nil && showResult == false {
            
            VStack(alignment: .leading) {
                
                // Question number
                Text("Question \(model.currentQuestionIndex + 1) of \(model.currentModule?.test.questions.count ?? 0)")
                    .padding(.leading, 20)
                
                // Question
                CodeTextView()
                    .padding(.horizontal, 20)
                
                // Answers
                ScrollView {
                    VStack {
                        ForEach(0..<model.currentQuestion!.answers.count, id : \.self) { index in
                            
                            Button(action: {
                                // track the selected index
                                selectedAnswerIndex = index
                            }, label: {
                                
                                // setting each button's color
                                ZStack {
                                    if submitted == false {
                                        RectangleCard(color: index == selectedAnswerIndex ? .gray : .white)
                                            .frame(height: 48)
                                    } else {
                                        // answer has been submitted
                                        if selectedAnswerIndex == index && index == model.currentQuestion!.correctIndex {
                                            
                                            // user selected right answer
                                            // show green rectangle
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                            
                                        } else if selectedAnswerIndex == index && index != model.currentQuestion!.correctIndex {
                                            
                                            // user selected wrong answer
                                            // show red rectangle
                                            RectangleCard(color: .red)
                                                .frame(height: 48)
                                            
                                        } else if index == model.currentQuestion!.correctIndex {
                                            
                                            // this button is the correct answer
                                            // show a green button
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                            
                                        } else {
                                            RectangleCard(color: .white)
                                                .frame(height: 48)
                                        }
                                    }
                                    
                                    Text(model.currentQuestion!.answers[index])
                                }
                                
                            })
                            .disabled(submitted)
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }
                
                // Submit Button
                
                Button(action: {
                    
                    // Check if answer has been submitted
                    if submitted {
                        
                        // Check if the last question
                        if model.currentQuestionIndex + 1 == model.currentModule!.test.questions.count {
                            showResult = true
                        } else {
                            // Not the last question
                            //Answer has already been submitted, move to next question
                            model.nextQuestion()
                            
                            // Reset properties
                            submitted = false
                            selectedAnswerIndex = nil
                        }
                    } else {
                        
                        // Change submitted state to true
                        submitted = true
                        // check correct answer
                        if selectedAnswerIndex == model.currentQuestion!.correctIndex {
                            numCorrect += 1
                        }
                    }
                    
                }, label: {
                    ZStack {
                        RectangleCard(color: .green)
                            .frame(height: 48)
                        
                        Text(buttonText)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                })
                .disabled(selectedAnswerIndex == nil)
            }
            .navigationBarTitle("\(model.currentModule?.category ?? "") Test")
            
        } else if showResult {
            
            // if currentQuestion = nil, show the result view
            TestResultView(numCorrect: numCorrect)
        }
        else {
            // Test hasn't loaded yet
            ProgressView() // spinning circle
        }
    }
    
    var buttonText: String {
        
        // Check if answer has been subimtted
        if submitted {
            if model.currentQuestionIndex + 1 == model.currentModule!.test.questions.count {
                return "Finish"
            } else {
                return "Next"
            }
        } else {
            return "Submit"
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
