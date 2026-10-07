//
//  ClassificationService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 04/10/2026.
//
//reference https://www.youtube.com/watch?v=EO7TAlMrUs4&t=765s

import Foundation
import CoreML
import UIKit
import Vision

struct ClassificationService {
    
    //instance of the service we can reference
    static let shared = ClassificationService()
    
    //instance of the classification model
    private let vnModel: VNCoreMLModel

    //initialize model
    private init() {
        //allows phone to use all available processing power
        let config = MLModelConfiguration()
        config.computeUnits = .all
        do {
            //instance of produceclassifier ML
            let ml = try ProduceClassifier(configuration: config)
            //point to model
            let model = ml.model
            //wrapping it for vision to process image
            self.vnModel = try VNCoreMLModel(for: model)
            
            let desc = model.modelDescription
            print(desc.inputDescriptionsByName.values.first as Any)
            


        } catch {
            //catch errors with loading the model
            assertionFailure("Failed to load model: \(error)")
            fatalError()
        }
    }

    // Still images
    //https://developer.apple.com/documentation/vision/vnclassificationobservation?changes=_2&language=objc
    //classify picutre and return a string
    func classifyProduce(_ image: UIImage) throws -> [String]? {
        //reads images cgImage - low level version of image for processing
        guard let cg = image.cgImage else { return nil }
        //create request
        let request = VNCoreMLRequest(model: vnModel)
        //https://developer.apple.com/documentation/vision/vngenerateimagefeatureprintrequest/imagecropandscaleoption
        //scale image to fill the expected 224x224 format
        request.imageCropAndScaleOption = .scaleFill
        //https://developer.apple.com/documentation/vision/vnimagerequesthandler processes images
        //orientation defaulted to .up - TODO: Review this later, as it might cause issues
        let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
        //model call
        try handler.perform([request])
        
        //results of classification - come out as VNClassificationObservation objects, where we then have to extract identifier (label) and confidence
        let results = (request.results as? [VNClassificationObservation]) ?? []
        //sorts them by percentage value
        let sorted  = results.sorted { $0.confidence > $1.confidence }
        let top3    = sorted.prefix(3).map {"\($0.identifier)"}
        
        print(top3)

        //top 5 most probably classifications
        //let top5    = sorted.prefix(5).map { "\($0.identifier)=\(Int($0.confidence * 100))%" }
        
        
        
        //returning the name of the classification label
        return top3
    }
}




