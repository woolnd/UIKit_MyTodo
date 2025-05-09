//
//  RecordingCreateViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/10/25.
//

import UIKit
import AVFoundation

struct recordingCreateModel {
    let id: String
    let title: String
    let time: String
    let date: String
}

class RecordingCreateViewController: UIViewController {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var recordedFileURL: URL? // 가장 최근 녹음 저장 위치
    var isRecording = false
    var recordingStartTime: Date?
    var timer: Timer?
    var currentRecordingID: String? // ✅ UUID 보관용
    
    var onRecordingCreated: (() -> Void)?  // ← 추가
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                                target: self,
                                                                action: #selector(closeTapped))
        resetButton.alpha = 0
        setTodayDateLabel()
        createButton.layer.cornerRadius = 10
        titleTextField.delegate = self
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
    
    @IBAction func recordingButtonTapped(_ sender: Any) {
        if isRecording {
            stopRecording()
        } else if let url = recordedFileURL {
            playRecording(url: url) // 녹음 완료 상태일 땐 재생
        } else {
            let id = UUID().uuidString
            currentRecordingID = id
            let url = getAudioFileURL(using: id)
            recordedFileURL = url
            startRecording()
        }
    }
    
    private func startRecording() {
        guard let url = recordedFileURL else { return }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            if session.isInputGainSettable {
                try session.setInputGain(1.0)
            }
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            recordingStartTime = Date()
            updateRecordingUI(state: "recording")
            startTimer()
        } catch {
            print("🎧 녹음 시작 실패: \(error)")
        }
    }
    
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingStartTime = nil
        stopTimer()
        updateRecordingUI(state: "done")
    }
    
    private func playRecording(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker) // ✅ 스피커 출력 설정
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("재생 실패: \(error)")
        }
    }
    
    func getAudioFileURL(using id: String) -> URL {
        let fileName = "\(id).m4a"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }
    
    private func updateRecordingUI(state: String? = nil) {
        switch state {
        case "recording":
            recordingButton.setImage(UIImage.voiceOn, for: .normal)
            recordingButton.setTitle("녹음중", for: .normal)
            recordingTimeLabel.text = "00:00"
            resetButton.alpha = 0
        case "done":
            recordingButton.setImage(UIImage.voiceOff, for: .normal)
            recordingButton.setTitle("재생하기", for: .normal)
            resetButton.alpha = 1
        default:
            recordingButton.setImage(UIImage.voiceOff, for: .normal)
            recordingButton.setTitle("녹음하기", for: .normal)
            recordingTimeLabel.text = "00:00"
            resetButton.alpha = 0
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let start = self.recordingStartTime else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            let minutes = String(format: "%02d", elapsed / 60)
            let seconds = String(format: "%02d", elapsed % 60)
            self.recordingTimeLabel.text = "\(minutes):\(seconds)"
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        audioRecorder?.stop()
        audioPlayer?.stop()
        isRecording = false
        recordedFileURL = nil
        recordingStartTime = nil
        stopTimer()
        updateRecordingUI() // 초기 상태로 복원
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("제목을 입력해주세요.")
            return
        }
        
        guard let id = currentRecordingID, recordedFileURL != nil else {
            showAlert("녹음을 먼저 진행해주세요.")
            return
        }
        let time = recordingTimeLabel.text ?? "00:00"
        let date = dateLabel.text ?? "Unknown Date"
        
        let model = recordingCreateModel(id: id, title: title, time: time, date: date)
        
        let viewModel = RecordingCreateViewModel()
        viewModel.process(.createRecording(model)) { [weak self] success in
            guard let self = self else { return }
            
            let message = success ? "녹음 생성 완료!!" : "녹음 생성 실패!!"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                if success {
                    self.dismiss(animated: true)
                    self.onRecordingCreated?()  // ✅ 성공 시 콜백 호출
                }
            })
            self.present(alert, animated: true)
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension RecordingCreateViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.endEditing(true)
        return true
    }
}
