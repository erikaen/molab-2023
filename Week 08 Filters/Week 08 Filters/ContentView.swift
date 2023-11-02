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
import CoreGraphics
import VideoToolbox



class CameraManager: ObservableObject {
  enum Status {
    case unconfigured
    case configured
    case unauthorized
    case failed
  }

  static let shared = CameraManager()

  @Published var error: CameraError?

  let session = AVCaptureSession()

  private let sessionQueue = DispatchQueue(label: "com.raywenderlich.SessionQ")
  private let videoOutput = AVCaptureVideoDataOutput()
  private var status = Status.unconfigured

  private init() {
    configure()
  }

  private func set(error: CameraError?) {
    DispatchQueue.main.async {
      self.error = error
    }
  }

  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video) { authorized in
        if !authorized {
          self.status = .unauthorized
          self.set(error: .deniedAuthorization)
        }
        self.sessionQueue.resume()
      }
    case .restricted:
      status = .unauthorized
      set(error: .restrictedAuthorization)
    case .denied:
      status = .unauthorized
      set(error: .deniedAuthorization)
    case .authorized:
      break
    @unknown default:
      status = .unauthorized
      set(error: .unknownAuthorization)
    }
  }

  private func configureCaptureSession() {
    guard status == .unconfigured else {
      return
    }

    session.beginConfiguration()

    defer {
      session.commitConfiguration()
    }

    let device = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: .front)
    guard let camera = device else {
      set(error: .cameraUnavailable)
      status = .failed
      return
    }

    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      if session.canAddInput(cameraInput) {
        session.addInput(cameraInput)
      } else {
        set(error: .cannotAddInput)
        status = .failed
        return
      }
    } catch {
      set(error: .createCaptureInput(error))
      status = .failed
      return
    }

    if session.canAddOutput(videoOutput) {
      session.addOutput(videoOutput)

      videoOutput.videoSettings =
        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

      let videoConnection = videoOutput.connection(with: .video)
      videoConnection?.videoOrientation = .portrait
    } else {
      set(error: .cannotAddOutput)
      status = .failed
      return
    }

    status = .configured
  }

  private func configure() {
    checkPermissions()

    sessionQueue.async {
      self.configureCaptureSession()
      self.session.startRunning()
    }
  }

  func set(
    _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
    queue: DispatchQueue
  ) {
    sessionQueue.async {
      self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
    }
  }
}


class FrameManager: NSObject, ObservableObject {
  static let shared = FrameManager()

  @Published var current: CVPixelBuffer?

  let videoOutputQueue = DispatchQueue(
    label: "com.raywenderlich.VideoOutputQ",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)

  private override init() {
    super.init()

    CameraManager.shared.set(self, queue: videoOutputQueue)
  }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    if let buffer = sampleBuffer.imageBuffer {
      DispatchQueue.main.async {
        self.current = buffer
      }
    }
  }
}


struct ContentView: View {
  @StateObject private var model = ContentViewModel()

  var body: some View {
    ZStack {
      FrameView(image: model.frame)
        .edgesIgnoringSafeArea(.all)

      ErrorView(error: model.error)

      ControlView(
        originalSelected: $model.originalFilter,
        pixellatedSelected: $model.pixellatedFilter,
        sepiatoneSelected: $model.sepiatoneFilter,
        sketchySelected: $model.sketchyFilter)
    }
  }
}

struct ErrorView: View {
  var error: Error?

  var body: some View {
    VStack {
      Text(error?.localizedDescription ?? "")
        .bold()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(8)
        .foregroundColor(.white)
        .background(Color.red.edgesIgnoringSafeArea(.top))
        .opacity(error == nil ? 0.0 : 1.0)
        .animation(.easeInOut, value: 0.25)

      Spacer()
    }
  }
}

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: CameraError.cannotAddInput)
  }
}

enum CameraError: Error {
  case cameraUnavailable
  case cannotAddInput
  case cannotAddOutput
  case createCaptureInput(Error)
  case deniedAuthorization
  case restrictedAuthorization
  case unknownAuthorization
}

extension CameraError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cameraUnavailable:
      return "Camera unavailable"
    case .cannotAddInput:
      return "Cannot add capture input to session"
    case .cannotAddOutput:
      return "Cannot add video output to session"
    case .createCaptureInput(let error):
      return "Creating capture input for camera: \(error.localizedDescription)"
    case .deniedAuthorization:
      return "Camera access denied"
    case .restrictedAuthorization:
      return "Attempting to access a restricted capture device"
    case .unknownAuthorization:
      return "Unknown authorization status for capture device"
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct ControlView: View {
  @Binding var originalSelected: Bool
  @Binding var pixellatedSelected: Bool
  @Binding var sepiatoneSelected: Bool
  @Binding var sketchySelected: Bool

  var body: some View {
    VStack {
      Spacer()

      HStack(spacing: 12) {
        ToggleButton(selected: $originalSelected, label: "Original")
        ToggleButton(selected: $pixellatedSelected, label: "Pixellated")
        ToggleButton(selected: $sepiatoneSelected, label: "Sepia Tone")
        ToggleButton(selected: $sketchySelected, label: "Sketchy")
      }
    }
  }
}

struct ToggleButton: View {
    @Binding var selected: Bool
    var label: String

    var body: some View {
        Button(action: {
            selected.toggle()
        }) {
            HStack {
                Text(label)
                Spacer()
                Image(systemName: selected ? "heart.fill" : "heart")
                    .foregroundColor(selected ? .white : .gray)
            }
        }
        .padding(10)
        .foregroundColor(selected ? .white : .black)
        .background(selected ? Color.gray : Color.white)
        .animation(.easeInOut, value: selected)
        .cornerRadius(10)
    }
}

struct ToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ToggleButton(selected: .constant(false), label: "Toggle")
        }
    }
}

struct ControlView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black
        .edgesIgnoringSafeArea(.all)

      ControlView(
        originalSelected: .constant(false),
        pixellatedSelected: .constant(true),
        sepiatoneSelected: .constant(true),
        sketchySelected: .constant(true))
    }
  }
}


struct PhotoData {
    let thumbnailImage: Image
    let thumbnailSize: (width: Int, height: Int)
    let imageData: Data
    let imageSize: (width: Int, height: Int)
}

extension CGImage {
  static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
    guard let pixelBuffer = cvPixelBuffer else {
      return nil
    }

    var image: CGImage?
    VTCreateCGImageFromCVPixelBuffer(
      pixelBuffer,
      options: nil,
      imageOut: &image)
    return image
  }
}

class ContentViewModel: ObservableObject {
  //  @Published var frame: UIImage?  // Store the captured photo as UIImage
  //  @Published var currentFilter: FilterType = .original
  //  var cameraManager: CameraManager
   // @Published var thumbnailImage: Image?
    @Published var error: Error?
    @Published var frame: CGImage?
    @Published var capturedPhoto: CGImage?

    
    var originalFilter  = false
    var sepiatoneFilter  = false
    var pixellatedFilter  = false
    var sketchyFilter  = false

    private let context = CIContext()

    private let cameraManager = CameraManager.shared
    private let frameManager = FrameManager.shared
    

    init() {
        setupSubscriptions()
    }
    
    func capturePhoto() {
        if let currentFrame = frame {
            capturedPhoto = currentFrame
        }
    }

    func setupSubscriptions() {
      // swiftlint:disable:next array_init
      cameraManager.$error
        .receive(on: RunLoop.main)
        .map { $0 }
        .assign(to: &$error)

      frameManager.$current
        .receive(on: RunLoop.main)
        .compactMap { buffer in
          guard let image = CGImage.create(from: buffer) else {
            return nil
          }

            var ciImage = CIImage(cgImage: image)
            
            if self.originalFilter {
              ciImage = CIImage(cgImage: image)
            }

            if self.sepiatoneFilter  {
              ciImage = ciImage.applyingFilter("CIPixellate")
            }

            if self.pixellatedFilter  {
              ciImage = ciImage.applyingFilter("CISepiaTone")
            }

            if self.sketchyFilter  {
              ciImage = ciImage.applyingFilter("CIComicEffect")
            }
            
            return self.context.createCGImage(ciImage, from: ciImage.extent)
          }
          .assign(to: &$frame)
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
    

struct FrameView: View {
  var image: CGImage?

  private let label = Text("Video feed")

  var body: some View {
    if let image = image {
      GeometryReader { geometry in
        Image(image, scale: 1.0, orientation: .upMirrored, label: label)
          .resizable()
          .scaledToFill()
          .frame(
            width: geometry.size.width,
            height: geometry.size.height,
            alignment: .center)
          .clipped()
      }
    } else {
      EmptyView()
    }
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    FrameView(image: nil)
  }
}


/*struct CameraView: View {
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
}*/

/*struct CameraPreview: View {
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
}*/




/*struct CaptureButton: View {
    @ObservedObject var contentViewModel: ContentViewModel

    var body: some View {
        Button("Capture Photo") {
            contentViewModel.cameraManager.takePhoto()
        }
        .offset(y: 150) // Adjust the button's position as needed
    }
}*/


/*enum FilterType: String, CaseIterable, Identifiable {
    case original = "Original"
    case sepiaTone = "Sepia Tone"
    case pixelated = "Pixellated"
    case sketchy = "Sketchy"

    var id: String { self.rawValue }

    var filter: CIFilter? {
        switch self {
            case .pixelated:
                return CIFilter(name: "CIPixellate")
            case .original:
                return nil
            case .sepiaTone:
                return CIFilter(name: "CISepiaTone")
            case .sketchy:
                return CIFilter(name: "CIComicEffect")
        }
    }
}*/

/*struct CameraRepresentable: UIViewControllerRepresentable {
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
}*/

/*class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
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
*/



/*extension CGImage {
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
}*/
