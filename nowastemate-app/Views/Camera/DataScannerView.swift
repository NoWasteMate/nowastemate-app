//
//  DataScannerView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-30.
//

// Reference video: https://www.youtube.com/watch?v=QQjLOlkxpvc

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    var onTap: ((RecognizedItem) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
        
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        context.coordinator.onTap = onTap
        
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recoginzedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        var onTap: ((RecognizedItem) -> Void)?
        
        init(recoginzedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recoginzedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            onTap?(item)
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            
            recognizedItems.append(contentsOf: addedItems)
            
            let hasBarcode = addedItems.contains { item in
                if case .barcode = item { return true }
                return false
            }
            
            if hasBarcode {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                //recognizedItems.append(contentsOf: addedItems)
                print("didAddItems \(addedItems)")
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            recognizedItems = recognizedItems.map { item in
                updatedItems.first(where: { $0.id == item.id }) ?? item
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: { $0.id == item.id })
            }
            
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
    }
}
