//
//  CrimeNextDoorApp.swift
//  CrimeNextDoor
//
//  Created by Oliver Harvey on 11/08/2021.
//

import SwiftUI

@main
struct CrimeNextDoorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(APIManager())
        }
    }
}
