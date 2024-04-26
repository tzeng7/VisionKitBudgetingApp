//
//  CameraView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Vision
import VisionKit


struct ReceiptRecognitionResult {
    let title: String?
    let date: Date?
    let total: Double?
}

struct CameraView : UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VNDocumentCameraViewController

    @Binding var entry: Expense
    
    func makeUIViewController(context: Context) -> Self.UIViewControllerType {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        
        return controller
    }

    func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Context) {
        return
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(entry: self.$entry)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        var entry: Binding<Expense>
        private let localPasteboard: UIPasteboard! = UIPasteboard(name: .init("BudgetingExpenseApp"), create: true)// .general

        init(entry: Binding<Expense>) {
            self.entry = entry.projectedValue
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Document recognition finished!")
            let image = scan.imageOfPage(at: 0)
            Task {
                let recognitionResult = await runTextRecognition(image: image)
                self.entry.wrappedValue = Expense() {
                    if let title = recognitionResult.title {
                        $0.name = title
                    }
                    if let price = recognitionResult.total {
                        $0.price = price
                    }
                    if let date = recognitionResult.date {
                        $0.date = date
                    }
                    $0.image = image
                }
                await controller.dismiss(animated: true)
                
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("Document recognition cancelled")
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            print(error)
        }
        
        private func runTextRecognition(image: UIImage) async -> ReceiptRecognitionResult {
            var textLines: [[String]] = []
            
            let textRecognitionRequest = VNRecognizeTextRequest { (req, error) in
                guard let observations = req.results as? [VNRecognizedTextObservation] else {
                    return
                }
                let sortedObservationsY = observations.sorted { left, right in
                    left.boundingBox.minY > right.boundingBox.minY
                }
                var lines: [Double] = []
                for observation in sortedObservationsY {
                    guard !(observation.topCandidates(1).first?.string ?? "").isEmpty else {
                        continue
                    }
                    if lines.isEmpty || !observation.boundingBox.contains(CGPoint(x: observation.boundingBox.midX, y: lines[lines.count - 1])) {
                        lines.append(observation.boundingBox.midY)
                    }
                }
                lines.sort(by: >)
                let grouped: [Int: [VNRecognizedTextObservation]] = Dictionary(grouping: observations) { observation in
                    let idx = lines.firstIndex { linePos in
                        observation.boundingBox.contains(CGPoint(x: observation.boundingBox.midX, y: linePos))
                    }
                    return idx ?? -1
                }
                
                for idx in 0..<lines.count {
                    textLines.append([])
                    let sortedObservationsX =  (grouped[idx] ?? []).sorted { left, right in
                        left.boundingBox.minX < right.boundingBox.minX
                    }
                    for observation in sortedObservationsX {
                        guard let recognizedText = observation.topCandidates(1).first?.string else {
                            print("No recognized text for observation: \(observation)")
                            continue
                        }
                        textLines[idx].append(recognizedText)
                    }
                }
                print("Observed lines: \(textLines)")
            }
            textRecognitionRequest.recognitionLevel = .accurate
            
            
            guard let cgImage = image.cgImage else {
                print("Failed to get cgimage from input image")
                fatalError()
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
            let receiptInfo = await convertLinesToReceiptRecognitionResult(lines: textLines)
            print(receiptInfo)
            return receiptInfo
        }
        
        private func convertLinesToReceiptRecognitionResult(lines: [[String]]) async -> ReceiptRecognitionResult {
            let title = lines[0].joined(separator: " - ")
            var date: Date? = nil
            for lineComponents in lines {
                let line = lineComponents.joined(separator: " ")
                let dates = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue).matches(in: line, range: NSRange(location: 0, length: line.count))
                    .compactMap { $0.date }
                date = dates?.first
                if date != nil {
                    break
                }
            }
            let lineWithTotal = lines.first { $0.first?.lowercased().starts(with: "total") == true || $0.first?.lowercased().starts(with: "balance") == true }
            let totalAmount = await detectCurrency(totalLine: lineWithTotal ?? [])
            return ReceiptRecognitionResult(title: title, date: date, total: totalAmount)
        }
        
        private func detectCurrency(totalLine: [String]) async -> Double? {
            defer { UIPasteboard.remove(withName: self.localPasteboard.name) }
            self.localPasteboard.addItems(totalLine.map {
                [UTType.utf8PlainText.identifier : $0]
            })
            print("Items on pasteboard: \(self.localPasteboard.items)")
            do {
                let detectedValues = try await self.localPasteboard.detectedValues(for: [\.moneyAmounts], inItemSet: IndexSet(integersIn: 0..<totalLine.count))
                if let currencyAmount = detectedValues.flatMap(\.moneyAmounts).first {
                    print("Detected \(currencyAmount.currency) \(currencyAmount.amount)")
                    return currencyAmount.amount
                }
            } catch {
                print("Error: \(error)")
            }
            return nil
            
        }
    }

}
