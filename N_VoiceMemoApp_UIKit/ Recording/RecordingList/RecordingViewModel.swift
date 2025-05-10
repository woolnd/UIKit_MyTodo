//
//  RecordingViewModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/10/25.
//

import Foundation
import FirebaseFirestore

final class RecordingViewModel: ObservableObject {
    enum Action {
        case loadData
        case getDataSuccess(RecordingResponse)
        case getDataFailure(Error)
        case deleteRecording(String)
    }
    
    final class State {
        struct viewModels {
            var recordingViewModels: [RecordingCellViewModel] = []
        }
        
        @Published var viewModels: viewModels = viewModels()
    }
    
    private(set) var state: State = State()
    private var loadDataTask: Task<Void, Never>?
    
    func process(_ action: Action) {
        switch action {
        case .loadData:
            loadData()
        case let .getDataSuccess(response):
            transformResponse(response)
        case let .getDataFailure(error):
            print(error)
        case let .deleteRecording(id):
            deleteRecording(id)
        }
    }
    
    deinit{
        loadDataTask?.cancel()
    }
}

extension RecordingViewModel {
    private func loadData() {
        loadDataTask = Task{
            do {
                let db = Firestore.firestore()
                let docRef = db.collection("Recording").document("List")
                
                let snapshot = try await docRef.getDocument()
                guard let response = try? snapshot.data(as: RecordingResponse.self)
                else { throw NSError(domain: "DecodingError", code: -1) }
                
                process(.getDataSuccess(response))
                
            } catch{
                process(.getDataFailure(error))
            }
        }
    }
    
    private func transformResponse(_ response: RecordingResponse){
        Task {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일 (E) - a h시 mm분" // 전체 날짜+시간 포맷으로 수정
            
            let sortedResponse = response.recording.sorted { recording1, recording2 in
                guard
                    let date1 = formatter.date(from: recording1.date),
                    let date2 = formatter.date(from: recording2.date)
                else {
                    return false
                }
                return date1 < date2
            }
            state.viewModels.recordingViewModels = sortedResponse.map{
                RecordingCellViewModel(id: $0.id, title: $0.title, time: $0.time, date: $0.date)
            }
        }
    }
    
    func deleteRecording(_ id: String) {
        Task {
            let db = Firestore.firestore()
            let docRef = db.collection("Recording").document("List")
            
            do {
                let snapshot = try await docRef.getDocument()
                guard var response = try? snapshot.data(as: RecordingResponse.self) else { return }
                
                response.recording.removeAll { $0.id == id }
                
                try docRef.setData(from: response)
                process(.loadData) // 다시 불러와서 갱신
            } catch {
                print("삭제 실패: \(error)")
            }
        }
    }
}
