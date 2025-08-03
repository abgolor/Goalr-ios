//
//  GoalrApp.swift
//  Goalr
//
//  Created by Golor Abraham AjiriOghene on 25/07/2025.
//

import SwiftUI

@main
struct GoalrApp: App {
    @StateObject private var viewModel = GoalrViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.user == nil {
                SplashView(viewModel: viewModel)
            } else {
                HomeView(viewModel: viewModel)
            }
        }
    }
}
