//
//  ContentView.swift
//  Week 08 Filters
//
//  Created by 项一诺 on 11/2/23.
//

import SwiftUI
import AVFoundation
import UIKit
import CoreImage
import Combine


struct ContentView: View {
    var body: some View {
        CameraView()
    }
}

struct PhotoData {
    let thumbnailImage: Image
    let thumbnailSize: (width: Int, height: Int)
    let imageData: Data
    let imageSize: (width: Int, height: Int)
}


class ContentViewModel: ObservableObject {
    @Published var frame: UIImage?  // Store the captured photo as UIImage
    @Published var currentFilter: FilterType = .original
    var cameraManager: CameraManager
    @Published var thumbnailImage: Image?
    
    
    


    init() {
        cameraManager = CameraManager()
        setupSubscriptions()
    }
    
   

    func setupSubscriptions() {
        cameraManager.$current
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                guard let image = CGImage.create(from: buffer) else {
                    return nil
                }
                return image
            }
            .sink { [weak self] image in
                self?.applyFilter(to: image)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []

    private func applyFilter(to image: CGImage) {
            let ciImage = CIImage(cgImage: image)

            if let filter = self.currentFilter.filter {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    let context = CIContext()
                    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                        let uiImage = UIImage(cgImage: cgImage)  // Convert to UIImage
                        DispatchQueue.main.async {
                            self.frame = uiImage  // Update the captured photo
                        }
                    }
                }
            }
        }
    
    /*  private func applyFilter(to image: CGImage) {
     let ciImage = CIImage(cgImage: image)

     if let filter = self.currentFilter.filter {
         filter.setValue(ciImage, forKey: kCIInputImageKey)
         if let outputImage = filter.outputImage {
             let context = CIContext()
             if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                 let uiImage = UIImage(cgImage: cgImage)  // Convert to UIImage
                 DispatchQueue.main.async {
                     self.frame = uiImage  // Update the captured photo
                 }
             }
         }
     }
 }*/
    }


struct CameraView: View {
    @StateObject private var contentViewModel = ContentViewModel()

    var body: some View {
        VStack {
            CameraPreview(contentViewModel: contentViewModel)
            Picker("Select Filter", selection: $contentViewModel.currentFilter) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            CaptureButton(contentViewModel: contentViewModel)
        }
    }
}

struct CameraPreview: View {
    @ObservedObject var contentViewModel: ContentViewModel

    var body: some View {
        ZStack {
            CameraRepresentable(session: contentViewModel.cameraManager.session)
            if let frame = contentViewModel.frame {
                Image(uiImage: frame)  // Display the captured photo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            CaptureButton(contentViewModel: contentViewModel)
        }
    }
}




struct CaptureButton: View {
    @ObservedObject var contentViewModel: ContentViewModel

    var body: some View {
        Button("Capture Photo") {
            contentViewModel.cameraManager.takePhoto()
        }
        .offset(y: 150) // Adjust the button's position as needed
    }
}


enum FilterType: String, CaseIterable, Identifiable {
    case original = "Original"
    case sepiaTone = "Sepia Tone"
    case pixelated = "Pixellated"
    case sketchy = "Sketchy"

    var id: String { self.rawValue }

    var filter: CIFilter? {
        switch self {
            case .original:
                return nil
            case .sepiaTone:
                return CIFilter(name: "CISepiaTone")
            case .pixelated:
                return CIFilter(name: "CIPixellate")
            case .sketchy:
                return CIFilter(name: "CIComicEffect")
        }
    }
}

struct CameraRepresentable: UIViewControllerRepresentable {
    var session: AVCaptureSession

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = uiViewController.view.layer.bounds
        uiViewController.view.layer.addSublayer(previewLayer)
    }
}

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var current: CMSampleBuffer?
    var session: AVCaptureSession
    private var photoOutput: AVCapturePhotoOutput?
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    
    override init() {
        session = AVCaptureSession()
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        // Setup photo output

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        session.addOutput(output)

        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = self.photoOutput, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.startRunning()
    }

    // Function to take a photo
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }

        sessionQueue.async {
            let photoSettings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    // AVCapturePhotoCaptureDelegate method to handle the completion of photo capture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            // Handle the error as needed
        } else {
            // Process the captured photo here
        }
    }
    internal func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation),
              let orientationValue = cgImageOrientation.rawValue as? UInt8 // Convert to UInt8
        else { return nil }

        let imageOrientation = Image.Orientation(rawValue: UInt8(orientationValue))!
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)

        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))

        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    

}



extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        current = sampleBuffer
    }
}

extension CGImage {
    static func create(from sampleBuffer: CMSampleBuffer?) -> CGImage? {
        guard let sampleBuffer = sampleBuffer, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: baseAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue)

        return context?.makeImage()
    }
}
