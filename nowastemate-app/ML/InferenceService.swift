//
//  InferenceService.swift
//  nowastemate-app
//
//  Created by Frederik Dahl Hansen on 26/09/2026.
//
//reference https://www.youtube.com/watch?v=EO7TAlMrUs4&t=765s

import Foundation
import CoreML
import UIKit
import Vision



final class InferenceService {
    static let shared = InferenceService()

    private let vnModel: VNCoreMLModel

    private init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        do {
            let ml = try ProduceClassifier(configuration: config)
            let model = ml.model
            self.vnModel = try VNCoreMLModel(for: model)
            
            let desc = model.modelDescription
            print(desc.inputDescriptionsByName.values.first as Any)
            

        } catch {
            assertionFailure("Failed to load model: \(error)")
            fatalError()
        }
    }

    // Still images
    func classify(_ image: UIImage) throws -> VNClassificationObservation? {
        guard let cg = image.cgImage else { return nil }
        let request = VNCoreMLRequest(model: vnModel)
        //https://developer.apple.com/documentation/vision/vngenerateimagefeatureprintrequest/imagecropandscaleoption
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
        try handler.perform([request])
        
        let results = (request.results as? [VNClassificationObservation]) ?? []
        let sorted  = results.sorted { $0.confidence > $1.confidence }
        let top5    = sorted.prefix(5).map { "\($0.identifier)=\(Int($0.confidence * 100))%" }
        print("Top5 (photo):", top5.joined(separator: ", "))

        return sorted.first
    }
}
