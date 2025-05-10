//
//  RecordingDetailViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/11/25.
//

import UIKit
import AVFoundation

class RecordingDetailViewController: UIViewController {
    
    var id: String?
    var recordingTitle: String?
    var date: String?
    var time: String?
    
    var audioPlayer: AVAudioPlayer?
    var isPlaying: Bool = false
    var playbackTimer: Timer?
    var playbackStartTime: Date?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = recordingTitle
        dateLabel.text = date
        endTimeLabel.text = time
        progressView.progress = 0.0
        
        // ✅ url을 먼저 구한 뒤 사용할 것
        if let id = id,
           let url = getAudioFileURL(using: id) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
            } catch {
                print("❌ viewDidLoad에서 오디오 로드 실패: \(error)")
            }
        } else {
            print("❌ viewDidLoad에서 id 또는 url 없음")
        }
        
        buttonImageResize("play.fill")
    }
    
    private func getAudioFileURL(using id: String) -> URL? {
        let fileName = "\(id).m4a"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        guard let id = id,
              let url = getAudioFileURL(using: id) else {
            print("❌ 파일 경로를 찾을 수 없습니다.")
            return
        }
        
        if isPlaying {
            audioPlayer?.pause()
            stopTimer()
            buttonImageResize("play.fill")
            isPlaying = false
            print("⏸ 녹음 재생 일시정지")
        } else {
            do {
                if audioPlayer == nil {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default)
                    try session.overrideOutputAudioPort(.speaker)
                    try session.setActive(true)
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.delegate = self
                    audioPlayer?.prepareToPlay()
                }
                
                audioPlayer?.play()
                playbackStartTime = Date()
                startTimer()
                
                buttonImageResize("pause.fill")
                isPlaying = true
                print("▶️ 녹음 재생 시작")
            } catch {
                print("❌ 녹음 재생 실패: \(error)")
            }
        }
    }
    
    private func startTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else { return }
            
            // ⏱ 타이머 레이블 업데이트
            let elapsed = Int(player.currentTime)
            let minutes = String(format: "%02d", elapsed / 60)
            let seconds = String(format: "%02d", elapsed % 60)
            self.timerLabel.text = "\(minutes):\(seconds)"
            
            // 📊 프로그레스바 업데이트
            let progress = Float(player.currentTime / player.duration)
            self.progressView.progress = progress
        }
    }
    
    private func stopTimer() {
        playbackTimer?.invalidate()
        
        playbackTimer = nil
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let player = audioPlayer else { return }
        
        player.currentTime = 0  // ⏪ 재생 위치를 처음으로
        player.play()           // ▶️ 재생 시작
        isPlaying = true
        buttonImageResize("pause.fill")
        startTimer()  // 타이머도 다시 시작
    }
    
    private func formattedTime(from seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func buttonImageResize(_ imageName: String) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let playImage = UIImage(systemName: imageName, withConfiguration: largeConfig)
        playButton.setImage(playImage, for: .normal)
    }
}

extension RecordingDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimer()
        timerLabel.text = "00:00"
        buttonImageResize("play.fill")
        print("⏹ 재생 완료")
        progressView.progress = 0.0  // 🔁 초기화
    }
}
