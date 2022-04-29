import PhotoEditorSDK
import SwiftUI

@available(iOS 14.0, *)
struct ContentView: View {
  /// Controlling the presentation state of the camera.
  @State private var cameraPresented = false

  /// Controlling the presentation state of the photo editor.
  @State private var pesdkPresented = false

  /// The `Photo` that should be presented in the `PhotoEditor`.
  @State private var photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: ".jpg")!)

  /// The `Photo` that has been taken in the `Camera`.
  @State private var selectedPhoto: Photo?

  /// The `PhotoEditModel` used to restore a previous state in the `PhotoEditor`.
  @State private var photoEditModel: PhotoEditModel?

  var body: some View {
    NavigationView {
      List {
        Button("Camera") {
          cameraPresented = true
        }
        .padding(5)
        Button("PhotoEditor") {
          pesdkPresented = true
        }
        .padding(5)
      }
      .navigationTitle("SwiftUIExample")
      .fullScreenCover(isPresented: $pesdkPresented, content: {
        PhotoEditor(photo: selectedPhoto ?? photo, configuration: buildConfiguration(), photoEditModel: photoEditModel)
          .onDidCancel {
            pesdkPresented = false
            photoEditModel = nil
            selectedPhoto = nil
          }
          .onDidFail { error in
            print("Editor finished with error: \(error.localizedDescription)")
            pesdkPresented = false
            photoEditModel = nil
            selectedPhoto = nil
          }
          .onDidSave { _ in
            pesdkPresented = false
            photoEditModel = nil
            selectedPhoto = nil
          }
          .ignoresSafeArea()
      })
      .fullScreenCover(isPresented: $cameraPresented, content: {
        Camera(configuration: buildConfiguration())
          .onDidCancel {
            cameraPresented = false
            selectedPhoto = nil
          }
          .onDidSave { result in
            if let data = result.data {
              selectedPhoto = Photo(data: data)
            }
            self.photoEditModel = result.model
            cameraPresented = false
          }
          .ignoresSafeArea()
      })
      .onChange(of: selectedPhoto, perform: { _ in
        if selectedPhoto != nil {
          pesdkPresented = true
        }
      })
    }
  }

  /// The `OpenWeatherProvider` used for the animated stickers.
  private var weatherProvider: OpenWeatherProvider = {
    let weatherProvider = OpenWeatherProvider(apiKey: nil, unit: .locale)
    weatherProvider.locationAccessRequestClosure = { locationManager in
      locationManager.requestWhenInUseAuthorization()
    }
    return weatherProvider
  }()

  /// Builds the `Configuration` used for the editor.
  private func buildConfiguration() -> Configuration {
    let configuration = Configuration { builder in
      // Configure camera
      builder.configureCameraViewController { options in
        // Just enable photos
        options.allowedRecordingModes = [.photo]
        // Show cancel button
        options.showCancelButton = true
      }

      // Configure editor
      builder.configurePhotoEditViewController { options in
        var menuItems = PhotoEditMenuItem.defaultItems
        menuItems.removeLast() // Remove last menu item ('Magic')

        options.menuItems = menuItems
      }

      // Configure sticker tool
      builder.configureStickerToolController { options in
        // Enable personal stickers
        options.personalStickersEnabled = true
        // Enable smart weather stickers
        options.weatherProvider = self.weatherProvider
      }

      // Configure theme
      builder.theme = .dynamic
    }

    return configuration
  }
}

@available(iOS 14.0, *)
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
