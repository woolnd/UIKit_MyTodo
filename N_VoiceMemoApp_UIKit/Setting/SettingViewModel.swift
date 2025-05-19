//
//  SettingViewModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/19/25.
//

import Foundation
import FirebaseFirestore

final class SettingViewModel: ObservableObject {
    enum Action {
        case loadData
        case getDataSuccess(todoCount: Int, memoCount: Int, recordingCount: Int)
        case getDataFailure(Error)
    }
    
    final class State {
        struct viewModels {
            var todoCount: Int = 0
            var memoCount: Int = 0
            var recordingCount: Int = 0
        }
        
        @Published var viewModels: viewModels = viewModels()
    }
    
    private(set) var state: State = State()
    private var loadDataTask: Task<Void, Never>?
    
    func process(_ action: Action) {
        switch action {
        case .loadData:
            loadData()
        case let .getDataSuccess(todoCount, memoCount, recordingCount):
            transformResponse(todoCount, memoCount, recordingCount)
        case let .getDataFailure(error):
            print(error)
        }
    }
    
    deinit{
        loadDataTask?.cancel()
    }
}

extension SettingViewModel {
    private func loadData() {
        loadDataTask = Task {
            do {
                let db = Firestore.firestore()
                
                async let todoSnapshot = db.collection("Todo").document("List").getDocument()
                async let memoSnapshot = db.collection("Memo").document("List").getDocument()
                async let recordingSnapshot = db.collection("Recording").document("List").getDocument()

                
                let (todoDoc, memoDoc, recordingDoc) = try await (todoSnapshot, memoSnapshot, recordingSnapshot)
                
                let todoResponse = try todoDoc.data(as: TodoResponse.self)
                let memoResponse = try memoDoc.data(as: MemoResponse.self)
                let recordingResponse = try recordingDoc.data(as: RecordingResponse.self)

                
                process(.getDataSuccess(
                    todoCount: todoResponse.todo.count,
                    memoCount: memoResponse.memo.count,
                    recordingCount: recordingResponse.recording.count
                ))
                
            } catch {
                process(.getDataFailure(error))
            }
        }
    }
    
    private func transformResponse(_ todoCount: Int, _ memoCount: Int, _ recordingCount: Int) {
        state.viewModels = State.viewModels(
                todoCount: todoCount,
                memoCount: memoCount,
                recordingCount: recordingCount
            )
    }
}

