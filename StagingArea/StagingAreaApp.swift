

import SwiftUI

@main

struct StagingAreaApp: App {
    
    let progress: Progress
    let prestageController: PrestageBrain

    init() {
        self.progress = Progress()

        self.prestageController = PrestageBrain()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .environmentObject(prestageController)
        }
        //     This will hide these from the main menu (as they're not relevant)
        .commands {
            //          CommandGroup(replacing: .newItem) { }
            //          CommandGroup(replacing: .undoRedo) { }
            //          CommandGroup(replacing: .pasteboard) { }
        }
    }
}
