//
//  ExpiryScanView.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-11-15.
//

import SwiftUI
import VisionKit

//  RecognizedDataType.text(languages:): https://developer.apple.com/documentation/visionkit/datascannerviewcontroller/recognizeddatatype/text(languages:textcontenttype:)
//  safeAreaInset: https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)
//  Permission messages copied from CameraView so both scanners say the same thing

struct ExpiryScanView: View {
    
    @EnvironmentObject private var cameraVM: CameraViewModel
    @StateObject private var vm = ExpiryScanViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onConfirm: (Date) -> Void
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Scan Expiry Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") { dismiss() }
                    }
                }
        }
        .task { await cameraVM.requestDataScanerAccessStatus() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch cameraVM.dataScannerAccessStatus {
        case .scannerAvailable:
            DataScannerView(
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: .text(languages: ["en-US", "fr-FR"]),
                recognizesMultipleItems: true,
                onTap: vm.parseTapped
            )
            .ignoresSafeArea()
            .safeAreaInset(edge: .bottom) { panel }
        case .cameraNotAvailable:
            unavailable("Your device doesn't have a camera")
        case .scannerNotAvailable:
            unavailable("Your device doesn't have support for scanning text with this app")
        case .cameraAccessNotGranted:
            unavailable("Please provide access to the camera in settings")
        case .notDetermined:
            ProgressView("Requesting camera access")
        }
    }
    
    // Bottom panel
    
    private var panel: some View {
        VStack(spacing: 12) {
            if let best = vm.bestCandidate {
                Text("Found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(best.date.formatted(date: .long, time: .omitted))
                    .font(.title2.bold())
                
                if best.date < .now {                             // 23:59:59 has passed, so the day is over
                    Label("This date has already passed", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
                
                Button("Use this date") { confirm(best.date) }
                    .buttonStyle(.borderedProminent)
                Button("Scan again") { vm.reset() }
            } else {
                Text("Point the camera at the best-before or expiry date")
                    .multilineTextAlignment(.center)
            }
            
            // other matches (and the second reading of an ambiguous date); tapping one is the user's choice
            if !otherCandidates.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(otherCandidates) { candidate in
                            Button(candidate.date.formatted(date: .abbreviated, time: .omitted)) {
                                confirm(candidate.date)
                            }
                            .buttonStyle(.glass)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private var otherCandidates: [ExpiryCandidate] {
        Array(vm.candidates.filter { $0.id != vm.bestCandidate?.id }.prefix(4))
    }

    private func confirm(_ date: Date) {
        onConfirm(date)
        dismiss()
    }
    
    private func unavailable(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message).multilineTextAlignment(.center)
            Button("Pick Date instead") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}
