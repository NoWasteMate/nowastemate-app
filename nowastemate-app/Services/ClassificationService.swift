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
    
    static let shared = ClassificationService()
    
    private let vnModel: VNCoreMLModel

    private init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        do {
            let ml = try ProduceClassifier(configuration: config)
            let model = ml.model
            self.vnModel = try VNCoreMLModel(for: model)
            
            let desc = model.modelDescription            

        } catch {
            assertionFailure("Failed to load model: \(error)")
            fatalError()
        }
    }

    // Still images
    //https://developer.apple.com/documentation/vision/vnclassificationobservation?changes=_2&language=objc
    func classifyProduce(_ image: UIImage) throws -> String? {
        guard let cg = image.cgImage else { return nil }
        let request = VNCoreMLRequest(model: vnModel)
        //https://developer.apple.com/documentation/vision/vngenerateimagefeatureprintrequest/imagecropandscaleoption
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
        try handler.perform([request])
        
        let results = (request.results as? [VNClassificationObservation]) ?? []
        let sorted  = results.sorted { $0.confidence > $1.confidence }
        //let top5    = sorted.prefix(5).map { "\($0.identifier)=\(Int($0.confidence * 100))%" }
        
        
        
        return sorted.first?.identifier
    }
}
