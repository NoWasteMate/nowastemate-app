//
//  CameraView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2025-11-30.
//

// Reference video: https://www.youtube.com/watch?v=QQjLOlkxpvc
// other references:
// https://developer.apple.com/documentation/swiftui/view/ondisappear(perform:)
// @ViewBuilder so resultView can return a different view per branch:
// https://developer.apple.com/documentation/swiftui/viewbuilder
// https://developer.apple.com/documentation/swiftui/progressview
// https://www.avanderlee.com/swiftui/viewbuilder/
// compactMap to drop non-barcode items:
// https://developer.apple.com/documentation/swift/sequence/compactmap(_:)

import SwiftUI
import VisionKit

struct CameraView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var vm: CameraViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented : Bool
    
//    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
//        ("All", .none),
//        ("URL", .URL),
//        ("Phone", .telephoneNumber),
//        ("Email", .emailAddress),
//        ("Address", .fullStreetAddress)
//    ]
    
    var body: some View {
        ZStack {
            switch vm.dataScannerAccessStatus {
            case .scannerAvailable:
                mainView
            case .cameraNotAvailable:
                Text("Your device doesn't have a camera")
            case .scannerNotAvailable:
                Text("Your device doesn't have support for scanning barcode with this app")
            case .cameraAccessNotGranted:
                Text("Please provide access to the camera in settings")
            case .notDetermined:
                Text("Requesting camera access")
            }
        }
    }
    
    private var mainView: some View {
        
        ZStack {
            DataScannerView(
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType,
                recognizesMultipleItems: vm.recognizesMultipleItems)
            .background {Color.gray.opacity(0.3)}
            .ignoresSafeArea()
            .id(vm.dataScannerViewId)
            .sheet(isPresented: .constant(true)) {
                bottomContainerView
                    .background(.ultraThinMaterial)
                    .presentationDetents([.medium, .fraction(0.25)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .onAppear {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                            return
                        }
                        controller.view.backgroundColor = .clear
                    }
            }
            // reference: https://stackoverflow.com/questions/78919404/how-do-i-fix-my-onchangeofperform-to-avoid-xcode-giving-me-a-deprecation-war
            .onChange(of: vm.scanType) {
                vm.recognizedItems = []
            }
//            .onChange(of: vm.textContentType) {
//                vm.recognizedItems = []
//            }
//            .onChange(of: vm.recognizesMultipleItems) {
//                vm.recognizedItems = []
//            }
        }
        
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    //Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                
                //Toggle("Scan multiple", isOn: $vm.recognizesMultipleItems)
            }.padding(.top)
            
//            if vm.scanType == .text {
//                Picker("Text content type", selection: $vm.textContentType) {
//                    ForEach(textContentTypes, id: \.self.textContentType) { option in
//                        Text(option.title).tag(option.textContentType)
//                    }
//                }.pickerStyle(.segmented)
//            }
            Text(vm.headerText).padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
    
        VStack {
            headerView
            resultView
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 16) {
//                    ForEach(vm.recognizedItems) { item in
//                        switch item {
//                        case .barcode(let barcode):
//                            Text(barcode.payloadStringValue ?? "Unknown barcode")
//                            
//                        case .text(let text):
//                            Text(text.transcript)
//                            
//                        @unknown default:
//                            Text("Unknown")
//                        }
//                    }
//                    
//                }
//                .padding()
//            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .padding(.top, 12)
        }
        //VisionKit keeps adding items for one barcode the view model helps with duplicates
        .onChange(of: vm.recognizedItems.count) {
            guard let user = authVM.user else { return }
            guard let barcode = vm.recognizedItems.compactMap({ item -> String? in
                if case .barcode(let barcode) = item { return barcode.payloadStringValue }
                return nil
            }).first else { return }
            
            productVM.lookUpBarcode(for: user, barcode: barcode)
        }
        .onDisappear {
            productVM.resetBarcodeLookup()
        }
    }
    
    @ViewBuilder
    private var resultView: some View {
        if productVM.isLookingUpBarcode {
            ProgressView("Looking up barcode")
                .padding()
        } else if let message = productVM.barcodeErrorMessage {
            VStack(spacing: 12) {
                Text(message)
                    .multilineTextAlignment(.center)
                HStack(spacing: 12) {
                    Button("Try Again") {
                        guard let user = authVM.user else { return }
                        productVM.retryBarcodeLookup(for: user)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if productVM.canAddManually {
                        Button("Add Manually") {
                           
                            productVM.scannedProduct = Product(name: "", quantity: 1, createdAt: "")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case .text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
}




