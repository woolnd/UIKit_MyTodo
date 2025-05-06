//
//  MemoViewModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import Foundation
import FirebaseFirestore

final class MemoViewModel: ObservableObject{
    enum Action {
        case loadData
        case getDataSuccess(MemoResponse)
        case getDataFailure(Error)
        case deleteMemo(String)
    }
    
    final class State {
        struct viewModels {
            var memoViewModels: [MemoCellViewModel] = []
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
            print(response)
            transformResponse(response)
        case let .getDataFailure(error):
            print(error)
        case let .deleteMemo(id):
            deleteTodo(id)
        }
    }
    
    deinit{
        loadDataTask?.cancel()
    }
}

extension MemoViewModel {
    private func loadData() {
        loadDataTask = Task{
            do {
                let db = Firestore.firestore()
                let docRef = db.collection("Memo").document("List")
                
                let snapshot = try await docRef.getDocument()
                guard let response = try? snapshot.data(as: MemoResponse.self)
                else { throw NSError(domain: "DecodingError", code: -1) }
                
                process(.getDataSuccess(response))
                
            } catch{
                process(.getDataFailure(error))
            }
        }
    }
    
    private func transformResponse(_ response: MemoResponse){
        Task {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일 (E) - a h시 mm분" // 전체 날짜+시간 포맷으로 수정
            
            let sortedResponse = response.memo.sorted { memo1, memo2 in
                guard
                    let date1 = formatter.date(from: memo1.date),
                    let date2 = formatter.date(from: memo2.date)
                else {
                    return false
                }
                return date1 < date2
            }
            state.viewModels.memoViewModels = sortedResponse.map{
                MemoCellViewModel(id: $0.id, title: $0.title, content: $0.content, date: $0.date)
            }
        }
    }
    
    func deleteTodo(_ id: String) {
        Task {
            let db = Firestore.firestore()
            let docRef = db.collection("Memo").document("List")
            
            do {
                let snapshot = try await docRef.getDocument()
                guard var response = try? snapshot.data(as: MemoResponse.self) else { return }
                
                response.memo.removeAll { $0.id == id }
                
                try docRef.setData(from: response)
                process(.loadData) // 다시 불러와서 갱신
            } catch {
                print("삭제 실패: \(error)")
            }
        }
    }
}
