//
//  TimerViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/15/25.
//

import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var EndTimeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    let sec = Array(0...59)
    let min = Array(0...59)
    let hour = Array(0...23)
    
    var selectedHour = 0
    var selectedMinute = 0
    var selectedSecond = 0
    
    var remainingTime: Int = 0
    var timer: Timer?
    
    var isPaused: Bool = false // 일시정지 여부 상태 관리
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        updateUI(false)
        
        
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        
        updateUI(true)
        
        
        selectedHour = hour[timePicker.selectedRow(inComponent: 0)]
        selectedMinute = min[timePicker.selectedRow(inComponent: 1)]
        selectedSecond = sec[timePicker.selectedRow(inComponent: 2)]
        
        // 총 시간(초)로 변환
        remainingTime = selectedHour * 3600 + selectedMinute * 60 + selectedSecond
        if remainingTime == 0 { return }
        
        // 종료 시각 계산
        let endDate = Date().addingTimeInterval(TimeInterval(remainingTime))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        EndTimeLabel.text = "\(formatter.string(from: endDate))"
        
        // 타이머 시작
        timer?.invalidate()
        startCountdown()
    }
    
    func startCountdown() {
        updateTimerLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingTime -= 1
            self.updateTimerLabel()
            
            if self.remainingTime <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.timerLabel.text = "00 : 00 : 00"
                self.EndTimeLabel.text = "00:00:00"
                self.stopButton.setTitle("일시 정지", for: .normal)
                self.isPaused = false
                self.updateUI(false)
            }
        }
    }
    
    func updateTimerLabel() {
        let h = remainingTime / 3600
        let m = (remainingTime % 3600) / 60
        let s = remainingTime % 60
        timerLabel.text = String(format: "%02d : %02d : %02d", h, m, s)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        updateUI(false)
        timer?.invalidate()
        timer = nil
        timerLabel.text = "00 : 00 : 00"
        EndTimeLabel.text = "00:00:00"
        stopButton.setTitle("일시 정지", for: .normal)
        isPaused = false
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        if isPaused {
            // ⏯ 재생 상태: 다시 시작
            isPaused = false
            stopButton.setTitle("일시 정지", for: .normal)
            
            // 종료 시간 재계산
            let newEndDate = Date().addingTimeInterval(TimeInterval(remainingTime))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            EndTimeLabel.text = "\(formatter.string(from: newEndDate))"
            
            // 타이머 재시작
            // ✅ 타이머가 nil일 때만 재시작 (중복 방지)
            if timer == nil {
                startCountdown()
            }
            
        } else {
            // ⏸ 정지 상태: 일시정지
            isPaused = true
            timer?.invalidate()
            timer = nil
            stopButton.setTitle("재생", for: .normal)
        }
    }
    
    func updateUI(_ input: Bool) {
        if input {
            timerView.alpha = 1
            cancelButton.alpha = 1
            stopButton.alpha = 1
            startButton.alpha = 0
        } else {
            timerView.alpha = 0
            cancelButton.alpha = 0
            stopButton.alpha = 0
            startButton.alpha = 1
        }
    }
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // 시, 분, 초
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hour.count
        case 1: return min.count
        case 2: return sec.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(hour[row]) 시간"
        case 1: return "\(min[row]) 분"
        case 2: return "\(sec[row]) 초"
        default: return nil
        }
    }
}
