//
//  MemoCreateViewModel.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import Foundation
import FirebaseFirestore

final class MemoCreateViewModel: ObservableObject{
    enum Action {
        case createMemo(memoCreateModel)
    }
    
    final class State {
        var createMemoViewModels: memoCreateModel?
    }
    
    private(set) var state: State = State()
    
    func process(_ action: Action, completion: @escaping (Bool) -> Void) {
        switch action {
        case let .createMemo(memo):
            saveMemoToFirestore(memo, completion: completion)
        }
    }
    
    func saveMemoToFirestore(_ memo: memoCreateModel, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let memoData: [String: Any] = [
            "id": memo.id,
            "title": memo.title,
            "content": memo.content,
            "date": memo.date
        ]
        
        let documentRef = db.collection("Memo").document("List")
        
        documentRef.updateData([
            "memo": FieldValue.arrayUnion([memoData])
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
