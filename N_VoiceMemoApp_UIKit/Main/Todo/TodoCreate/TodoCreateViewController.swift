//
//  TodoCreateViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/4/25.
//

import UIKit

struct todoCreateModel {
    let id: String
    let title: String
    let date: String
    let time: String
    let isCompleted: Bool
}

class TodoCreateViewController: UIViewController {
    
    @IBOutlet weak var todoCreateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    
    var onTodoCreated: (() -> Void)?  // ← 추가
    
    private var viewModel: TodoCreateViewModel = TodoCreateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                                target: self,
                                                                action: #selector(closeTapped))
        todoCreateButton.layer.cornerRadius = 10
        setTodayDateLabel()
        setupDoneButtonOnKeyboard()
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setTodayDateLabel() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 (E)"  // E는 요일
        
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    @IBAction func todoCreateButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: nil, message: "제목을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "a h시 mm분"
        
        let time = timeFormatter.string(from: datePicker.date)
        
        let model = todoCreateModel(
            id: UUID().uuidString,
            title: title,
            date: dateLabel.text ?? "오늘",
            time: time,
            isCompleted: false
        )
        
        viewModel.process(.createTodo(model)) { [weak self] success in
            guard let self = self else { return }
            
            let message = success ? "Todo 생성 완료!!" : "Todo 생성 실패!!"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                if success {
                    self.dismiss(animated: true)
                    self.onTodoCreated?()  // ✅ 성공 시 콜백 호출
                }
            })
            self.present(alert, animated: true)
        }
    }
    
    private func setupDoneButtonOnKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexibleSpace, doneButton]
        titleTextField.inputAccessoryView = toolbar
    }

    @objc private func doneButtonTapped() {
        view.endEditing(true) // 키보드 내림
    }
}
