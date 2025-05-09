//
//  RecordingModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/10/25.
//

import Foundation

struct RecordingResponse: Codable {
    var recording: [recording]
}

struct recording: Codable {
    let id: String
    let title: String
    let time: String
    let date: String
}
