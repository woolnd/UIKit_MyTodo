//
//  MemoCreateViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/6/25.
//

import UIKit

struct memoCreateModel {
    let id: String
    let title: String
    let content: String
    let date: String
}

class MemoCreateViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoCreateButton: UIButton!
    
    let textViewPlaceHolder = "내용을 입력하세요."
    
    var onMemoCreated: (() -> Void)?  // ← 추가
    
    private var viewModel: MemoCreateViewModel = MemoCreateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                                target: self,
                                                                action: #selector(closeTapped))
        
        memoCreateButton.layer.cornerRadius = 10
        titleTextField.delegate = self
        contentTextView.delegate = self
        setupDoneButtonOnKeyboard()
        setTodayDateLabel()
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setTodayDateLabel() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 (E) - a h시 mm분"

        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func setupDoneButtonOnKeyboard() {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
            
            toolbar.items = [flexibleSpace, doneButton]
            contentTextView.inputAccessoryView = toolbar
        }
        
        @objc private func doneButtonTapped() {
            view.endEditing(true) // 키보드 내림
        }
    @IBAction func memoCreateButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: nil, message: "제목을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let content = contentTextView.text ?? ""

        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content == textViewPlaceHolder {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let model = memoCreateModel(
            id: UUID().uuidString,
            title: title,
            content: content,
            date: dateLabel.text ?? "오늘"
        )
        
        viewModel.process(.createMemo(model)) { [weak self] success in
            guard let self = self else { return }
            
            let message = success ? "Memo 생성 완료!!" : "Memo 생성 실패!!"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                if success {
                    self.dismiss(animated: true)
                    self.onMemoCreated?()  // ✅ 성공 시 콜백 호출
                }
            })
            self.present(alert, animated: true)
        }
    }
}

extension MemoCreateViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.endEditing(true)
        return true
    }
}

extension MemoCreateViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if contentTextView.text == textViewPlaceHolder {
            contentTextView.text = nil
            contentTextView.textColor = .bk
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentTextView.text = textViewPlaceHolder
            contentTextView.textColor = .gray2
        }
    }
}
