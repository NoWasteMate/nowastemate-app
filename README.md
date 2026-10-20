<img width="121" height="121" alt="Image" src="https://github.com/user-attachments/assets/4356bbdb-f738-4fa0-ae57-aed482d0e6d3" />

# NoWasteMate Frontend

SwiftUI iOS app for NoWasteMate.

## Requirements

- macOS with Xcode 26
- iOS 26 simulator or iPhone
- The backend, either the deployed Cloud Run one or a [local one](https://github.com/NoWasteMate/nowastemate-backend#run-locally)

## Run locally

1. Open `nowastemate-app.xcodeproj` in Xcode. Swift packages (Firebase, FuzzyMatch) download on first open.
2. Pick a simulator or your personal iPhone and click run

To run on your own iPhone, go to the `nowastemate-app` target -> Signing & Capabilities and pick your Personal Team. A free Apple ID works. If Xcode says the bundle ID is taken, change it to something unique, like `com.yourname.nowastemate`.

`GoogleService-Info.plist` is already in the project, so Firebase sign-in works with no extra setup.

## Using a local backend

The app calls the deployed backend by default. To use one running on your Mac, change `baseUrl` in `nowastemate-app/AppConfig.swift`:

| Running on | `baseUrl` |
|---|---|
| Simulator | `http://127.0.0.1:8000` |
| iPhone (same Wi-Fi) | `http://<your Mac's IP>:8000`, with the backend started using `--host 0.0.0.0` |

Make sure to change `baseUrl` back before committing!

