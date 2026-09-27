//
//  MLTest.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 26/09/2026.
//

import SwiftUI
import SwiftUI
import Vision
import PhotosUI
//reference https://www.youtube.com/watch?v=EO7TAlMrUs4&t=765s
struct MLTest: View {
    
    @State var result: String = ""
        
    let img: UIImage = UIImage(named: "banana")!

    var body: some View {
        
        VStack (spacing: 16){
            Text("Input test")
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: 300)
            
            Button {
                classifyImage()
            } label: {
                Text("Run Test")
            }
            Text(result)
        }
        
    }
    
    func classifyImage() {
        do {
            guard let result = try
                    InferenceService.shared.classify(img) else {
                throw NSError(domain: "Error", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "No classification result"])
            }
            self.result = "\(result.identifier): \(result.confidence * 100)"
        }
        catch {
            print("error")
        }
    }
}


#Preview {
    MLTest()
}
