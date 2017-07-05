//
//  ViewController.swift
//  Transcribe
//
//  Created by Roland Shen on 5/10/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import SCLAlertView

class RecordingViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    //Speech recognition vars
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //Recording vars
    var recordButton: UIButton?
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var timer = Timer()
    var isTimerRunning = false
    var counter = 0
    
    var fileName = "recording.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        microphoneButton.isEnabled = false
        speechRecognizer.delegate = self
        
        //Recording
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //tbd
                    }
                    else {
                        SCLAlertView().showError("Failed to record", subTitle: "Check microphone settings.")
                    }
                }
            }
        }
        catch {
            SCLAlertView().showError("Failed to record", subTitle: "Check microphone settings.")
        }
        
        
        //Recognition
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    func timeString(time: Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            timer.invalidate()
            counter = 0
            timerLabel.text = "00:00:00"
        } else {
            startSpeechRecognition()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func updateCounter() {
        counter += 1
        timerLabel.text = timeString(time: counter)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        print("Path: " + getDocumentsDirectory().path)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordButton?.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }

    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            let setTitleAlert = SCLAlertView()
            microphoneButton.setTitle("START", for: .normal)
            setTitleAlert.addTextField()
            //save the text here as title
            //setTitleAlert.addButton("Save", target: self, selector: #selector())
            setTitleAlert.showSuccess("New recording", subTitle: "Enter a recording name")
        } else {
            microphoneButton.setTitle("STOP", for: .normal)
             SCLAlertView().showError("Failed to record", subTitle: "Check microphone settings.")
        }
    }
    
    func startSpeechRecognition() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        microphoneButton.setTitle("Stop", for: .normal)
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
