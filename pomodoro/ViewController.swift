//
//  ViewController.swift
//  pomodoro
//
//  Created by 백시훈 on 2022/09/17.
//

import UIKit
import AudioToolbox

enum TimerStatus{
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    /**
     타이머의 시간을 초 단위로 저장하는 프로퍼티
     datePicker의 defualt시간이 1분이기때문에 60으로 초기화
     */
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }

    @IBAction func tabCancelButton(_ sender: UIButton) {
        switch self.timerStatus{
        case .start, .pause:
            
            self.stopTimer()
        default:
            break
        }
    }
    /**
     타이머를 취소시키는 메서드
     */
    func stopTimer(){
        //타이머를 suspend로 멈추고 nil를 넣으면 에러가 나기때문에 직전에 timer를 resume상태로 전환해야한다.
        if self.timerStatus == .pause{
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.alpha = 1
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            //이미지 뷰 되돌리기 
            self.imageView.transform = .identity
        })
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        //타이머 종료시 반드시 메모리를 해제시켜야 한다.
        //아니면 백그라운드에서 계속 타이머가 돌아감
        self.timer = nil
        
    }
    /**
     타이머를 실행시키는 메서드
     */
    func startTimer(){
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: {[weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                self.progressView.progress = Float(self.currentSeconds)/Float(self.duration)
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                
                if self.currentSeconds <= 0{
                    //타이머가 종료될때
                    self.stopTimer()
                    //종료 알람 import AudioToolbox
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    /**
     타이머와 프로그래스뷰의 hidden을 조정하는 메서드
     */
    func setTimerInfoViewVisble(isHidden: Bool){
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    /**
     시작버튼을 일시정지로 변경하는 메서드
     일반상태에서는 시작, 버튼이 선택되면 일시정지로 변경
     */
    func configureToggleButton(){
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    @IBAction func tabToggleButton(_ sender: UIButton) {
        //self.datePicker.countDownDuration는 datePicker의 시간을 초단위로 반환하는 메서드
        //ex) 1분 =60 2분 = 120
        self.duration = Int(self.datePicker.countDownDuration)
        
        switch self.timerStatus{
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5, animations: {
                self.datePicker.alpha = 0
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
            })
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
        case .pause :
            self.toggleButton.isSelected = true
            self.timerStatus = .start
            self.timer?.resume()
        }
        
        
    }
    
}

