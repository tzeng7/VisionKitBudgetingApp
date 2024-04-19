//
//  CameraView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI
import UIKit
import Vision
import VisionKit


struct ReceiptRecognitionResult {
    let title: String?
    let date: Date?
    let total: String?
    
}

struct CameraView : UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VNDocumentCameraViewController

    @Binding var entry: Entry
    
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
        
        var entry: Binding<Entry>

        init(entry: Binding<Entry>) {
            self.entry = entry.projectedValue
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Document recognition finished!")
            var scanned = [UIImage]()
            for i in 0..<scan.pageCount {
                scanned.append(scan.imageOfPage(at: i))
            }
            let recognitionResult = runTextRecognition(image: scanned[0])
            self.entry.wrappedValue = Entry() {
                if let title = recognitionResult.title {
                    $0.name = title
                }
                if let priceString = recognitionResult.total, let price = Double(priceString) {
                    $0.price = price
                }
                if let date = recognitionResult.date {
                    $0.date = date
                }
                if let image = scanned.first {
                    $0.image = image
                }
            }
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("Document recognition cancelled")
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            print(error)
        }
        
        private func runTextRecognition(image: UIImage) -> ReceiptRecognitionResult {
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
            let receiptInfo = convertLinesToReceiptRecognitionResult(lines: textLines)
            print(receiptInfo)
            return receiptInfo
        }
        
        private func convertLinesToReceiptRecognitionResult(lines: [[String]]) -> ReceiptRecognitionResult {
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
            let lineWithTotal = lines.first { $0.first?.lowercased() == "total" }
            // TODO: run currency detection to grab double
            let total = lineWithTotal?.last
            let totalDoubleString = (total?.dropFirst()).map { String($0) }
            return ReceiptRecognitionResult(title: title, date: date, total: totalDoubleString)
        }
    }

}
