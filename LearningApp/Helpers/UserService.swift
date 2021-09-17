//
//  UserService.swift
//  LearningApp
//
//  Created by Edward Phan on 2021-09-15.
//

import Foundation

class UserService {
    
    var user = User()
    
    static var shared = UserService()
    
    private init() {
        
    }
}
