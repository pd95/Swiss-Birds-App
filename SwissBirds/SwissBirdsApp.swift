//
//  SwissBirdsApp.swift
//  SwissBirds
//
//  Created by Philipp on 06.03.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI
import SpeciesCore
import SpeciesUI

@main
struct SwissBirdsApp: App {
    let repository: SpeciesRepository

    init() {
        let client = RemoteDataClient(urlSession: .shared)
        let service = RemoteDataService(dataClient: client, language: "en")
        let repository = SpeciesRepository(service: service)

        self.repository = repository
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repository)
                .task {
                    do {
                        try await repository.refreshSpecies()
                    } catch {
                        print("🔴 refresh species and filters failed", error.localizedDescription)
                    }
                }
        }
    }
}
