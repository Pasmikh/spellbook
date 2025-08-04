import SwiftUI

@main
struct SpellbookApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            // This is required for the app to run, but we are not showing any settings window.
        }
    }
}