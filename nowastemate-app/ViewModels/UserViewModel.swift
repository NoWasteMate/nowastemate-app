//
//  UserViewModel.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 23/11/2025.
//

import Foundation
//this is needed post Xcode 26 https://www.linkedin.com/posts/mohammad-azam-5537993_import-combine-is-mandatory-when-using-observableobject-activity-7383151295664177152-kbPp/
import Combine

final class UserViewModel: ObservableObject{
    
    @Published var user: User = User(first: "T", last: "E", email: "S", password: "T")
    
    //ref https://www.youtube.com/watch?v=o3Rkg6WmZoY
    
    func addUser(obj: User){
        //make data into a string
        
        let url = URL(string: "http://127.0.0.1:8000/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
              
        let body: [String: AnyHashable] = [
            "first": obj.first,
            "last": obj.last,
            "email": obj.email,
            "password": obj.password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(response)
            }
            
            catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
    
}
