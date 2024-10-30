//
//  MissionApp.swift
//  Mission
//
//  Created by user257756 on 9/24/24.
//

import SwiftUI
import Firebase

@main
struct MissionApp: App {
    // Initialize Firebase in the initializer
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView() // This will be the main content of your app
            }
        }
    }
}


 
