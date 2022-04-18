//
//  ContentView-ViewModel.swift
//  JoshanRai-BucketList
//
//  Created by Joshan Rai on 4/17/22.
//

import Foundation
import MapKit
import LocalAuthentication

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        //  Map-based variables/constants
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        
        //  Authentication-based variables/constants
        @Published var authenticationError = "Unknown Error"
        @Published var isShowingAuthenticationError = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        //  Initializer for the data's save path on a user's device for locations
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
                print("Error: \(error.localizedDescription)")
            }
        }
        
        //  Save data to the specified path, return an error if unable to save the data
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data. \nError: \(error.localizedDescription)")
            }
        }
        
        //  Add a location to the array of Locations
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        //  Update location and save the data
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }

            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        //  Authenticate for the user
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Plase authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                        } else {
                            self.authenticationError = "There was a problem authentication you. Please try again."
                            self.isShowingAuthenticationError = true
                        }
                    }
                }
            } else {
                authenticationError = "Sorry, your device doesn't support biometric authentication."
                isShowingAuthenticationError = true
            }
        }
    }
}
