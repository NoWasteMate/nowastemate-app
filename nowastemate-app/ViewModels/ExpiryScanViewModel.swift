//
//  ExpiryScanViewModel.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-11-15.
//

// References:
//  RecognizedItem: https://developer.apple.com/documentation/visionkit/recognizeditem
//  Task.sleep(for:): https://developer.apple.com/documentation/swift/task/sleep(for:tolerance:clock:)
//  Same @MainActor ObservableObject pattern as CameraViewModel (reference video: https://www.youtube.com/watch?v=QQjLOlkxpvc)


import Foundation
import SwiftUI
import VisionKit
import Combine

@MainActor
final class ExpiryScanViewModel: ObservableObject {
    
    @Published var recognizedItems: [RecognizedItem] = [] { didSet { process() } }
    @Published private(set) var candidates: [ExpiryCandidate] = []
    @Published private(set) var bestCandidate: ExpiryCandidate?
    
    private var pendingDate: Date?
    private var stabilityTask: Task<Void, Never>?
    
    func process() {
        guard bestCandidate == nil else { return }
        
        // stop updating once a date is suggested
        let lines = recognizedItems.compactMap { item -> String? in
            if case .text(let text) = item { return text.transcript }
            return nil
        }
        candidates = ExpiryDateParser.candidates(lines: lines)
        
        let top = candidates.first?.date
        guard top != pendingDate else { return }                 // same top date: let the timer keep running
        pendingDate = top
        stabilityTask?.cancel()
        guard let top else { return }
        
        stabilityTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard let self, !Task.isCancelled,
                  let current = self.candidates.first, current.date == top else { return }
            self.suggest(current)
        }
    }
    
    // the user tapped a highlighted box: skip the timer, they chose it
    func parseTapped(_ item: RecognizedItem) {
        guard case .text(let text) = item,
              let match = ExpiryDateParser.candidates(lines: [text.transcript]).first else { return }
        stabilityTask?.cancel()
        suggest(match)
    }
    
    // "Scan again"
    func reset() {
        stabilityTask?.cancel()
        pendingDate = nil
        bestCandidate = nil
        candidates = []
        process()
    }
    
    private func suggest(_ candidate: ExpiryCandidate) {
        bestCandidate = candidate
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
