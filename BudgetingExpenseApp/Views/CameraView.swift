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

struct CameraView : View {
    var body: some View {
        ZStack {
            ViewControllerPreview()
        }
    }
}

struct ReceiptRecognitionResult {
    let title: String?
    let date: Date?
    let total: String?
    
}

class ViewController : UIViewController, VNDocumentCameraViewControllerDelegate {
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    //    let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    let viewController = VNDocumentCameraViewController()
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        viewController.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var scanned = [UIImage]()
        for i in 0..<scan.pageCount {
            scanned.append(scan.imageOfPage(at: i))
        }
        let recognitionResult = runTextRecognition(image: scanned[0])
        viewController.dismiss(animated: true)
        let index = recognitionResult.total!.index(recognitionResult.total!.startIndex, offsetBy: 1)
        print(recognitionResult.total!.suffix(from: index))
        let hostingController = UIHostingController(rootView: EntryView(isShowingForm: true, name: recognitionResult.title!, price: Double(recognitionResult.total!.suffix(from: index))!, date: recognitionResult.date!, image: scanned[0]))
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        print(error)
        viewController.dismiss(animated: true)
    }
     
    func runTextRecognition(image: UIImage) -> ReceiptRecognitionResult {
        var textLines: [[String]] = []
        
        textRecognitionRequest = VNRecognizeTextRequest { (req, error) in
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
                print("Observation: \(observation.topCandidates(1).first?.string ?? "")")
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
        let total = lineWithTotal?.last
        return ReceiptRecognitionResult(title: title, date: date, total: total)
    }
}

struct ViewControllerPreview : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


