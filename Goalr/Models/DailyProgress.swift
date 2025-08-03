//
//  DailyProgress.swift
//  Goalr
//
//  Created by Golor Abraham AjiriOghene on 30/07/2025.
//


import Foundation

struct DailyProgress: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var steps: Int
    var goalMet: Bool
}
