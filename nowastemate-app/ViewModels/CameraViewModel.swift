//
//  AppViewModel.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-30.
//

// Reference video: https://www.youtube.com/watch?v=QQjLOlkxpvc
// https://developer.apple.com/documentation/vision/barcodesymbology

import AVKit
import Foundation
import SwiftUI
import VisionKit
import Vision
import Combine

enum ScanType: String {
    //case barcode, text
    case barcode
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

// the viewmodel will be updated in the main thread
@MainActor
final class CameraViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    // @Published var textContentType: DataScannerViewController.TextContentType?
    // false for now (only want this to scan one barcode)
    @Published var recognizesMultipleItems = false
    
    private let classificationService = ClassificationService.shared
    
//    var recognizedDataType: DataScannerViewController.RecognizedDataType {
//        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
//    }
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        .barcode(symbologies: [.ean8, .ean13, .upce])
    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
//        hasher.combine(recognizesMultipleItems)
//        if let textContentType {
//            hasher.combine(textContentType)
//        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScanerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default: break
            
        }
    }
    
    func getClassification(img: UIImage) -> String? {
        
        do {
            let classification = try classificationService.classifyProduce(img)
            return classification
            
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
}
