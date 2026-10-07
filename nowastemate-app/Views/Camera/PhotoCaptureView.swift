//
//  PhotoView.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 04/10/2026.
//



import SwiftUI
import UIKit
//https://appcoda.com/swiftui-camera-photo-library/  From this tutorial on taking pictures from an app
//https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit
//special type of view that will instead show the camera
struct PhotoCaptureView: UIViewControllerRepresentable {

    //specify it is from the camera, another option is existing photos
    var sourceType: UIImagePickerController.SourceType = .camera
    //the image that will be assigned once we have taken photo
    @Binding var selectedImage: UIImage
    //used later to dismiss the view
    @Environment(\.presentationMode) private var presentationMode
    
    
    //build the actual screen to take photo
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoCaptureView>) -> UIImagePickerController {
        
        //create the object
        let imagePicker = UIImagePickerController()
        //disabled the native editing you would otherwise have available, does not make sense for us
        imagePicker.allowsEditing = false
        //specifies source
        imagePicker.sourceType = sourceType
        //send actions to coordinator below
        imagePicker.delegate = context.coordinator


        return imagePicker
    }

    //mandatory func for this type of view, but not needed currently in our scenario, therefore empty currently
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<PhotoCaptureView>) {
        
        
    }
    //class that receives the actions from the camera
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        //instance of the view
        var parent: PhotoCaptureView

        //runs when we create the coordinator and stores view
        init(_ parent: PhotoCaptureView) {
            self.parent = parent
        }
        //called once user confirms they want to use photo
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //when user presses use photo we store the photo to selectedImage, which is then used for processing by the ML later
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            //closes view
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    //called when this view is loaded
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
