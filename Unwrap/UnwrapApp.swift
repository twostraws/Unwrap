//
//  UnwrapApp.swift
//  Unwrap
//

import AVFAudio
import SwiftUI

@main
struct UnwrapApp: App {
    @UIApplicationDelegateAdaptor(UnwrapApplicationDelegate.self) private var appDelegate

    @State private var user: User
    @State private var newsStore: NewsStore
    @State private var challengesModel: ChallengesModel

    private let homeContent: HomeContent

    init() {
        if User.isRunningTests {
            User.destroyTestUser()
        }

        let user = if User.isRunningTests {
            User.load(testMode: true) ?? User()
        } else {
            User.synchronize() ?? User()
        }
        user.reconcileStreak(at: .now)

        do {
            homeContent = try HomeContent()
        } catch {
            preconditionFailure("Unable to load Home content: \(error)")
        }

        _user = State(initialValue: user)
        _newsStore = State(initialValue: NewsStore(user: user))
        _challengesModel = State(initialValue: ChallengesModel(user: user))

        // Lesson videos should play their sound even when the device is set to silent.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if User.isRunningTests {
                    Color.clear
                } else {
                    UnwrapRootView(homeContent: homeContent)
                }
            }
            .environment(user)
            .environment(newsStore)
            .environment(challengesModel)
        }
    }
}
