//
//  RecordingCreateViewModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/10/25.
//

import Foundation
import FirebaseFirestore

final class RecordingCreateViewModel: ObservableObject{
    enum Action {
        case createRecording(recordingCreateModel)
    }
    
    final class State {
        var createRecordingViewModels: recordingCreateModel?
    }
    
    private(set) var state: State = State()
    
    func process(_ action: Action, completion: @escaping (Bool) -> Void) {
        switch action {
        case let .createRecording(recording):
            saveRecordingToFirestore(recording, completion: completion)
        }
    }
    
    func saveRecordingToFirestore(_ recording: recordingCreateModel, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let recordingData: [String: Any] = [
            "id": recording.id,
            "title": recording.title,
            "time": recording.time,
            "date": recording.date
        ]
        
        let documentRef = db.collection("Recording").document("List")
        
        documentRef.updateData([
            "recording": FieldValue.arrayUnion([recordingData])
        ]) { error in
            if let error = error {
                print("❌ 저장 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Firestore 저장 성공!")
                completion(true)
            }
        }
    }
}
