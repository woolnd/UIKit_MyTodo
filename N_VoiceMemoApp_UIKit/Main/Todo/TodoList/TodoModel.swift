//
//  TodoModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/3/25.
//

import Foundation

struct TodoResponse: Codable {
    var todo: [todo]
}

struct todo: Codable {
    let id: String
    let title: String
    let date: String
    let time: String
    var isCompleted: Bool
}


