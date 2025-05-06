//
//  MemoModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import Foundation

struct MemoResponse: Codable {
    var memo: [memo]
}

struct memo: Codable {
    let id: String
    let title: String
    let content: String
    let date: String
}


