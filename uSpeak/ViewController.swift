//
//  ViewController.swift
//  uSpeak
//
//  Created by Adrien Maranville on 7/16/17.
//  Copyright © 2017 Adrien Maranville. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    let speechRecognizer = SFSpeechRecognizer()!
    
    let audioEngine = AVAudioEngine()

    var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    var recognitionTask = SFSpeechRecognitionTask()
    
    @IBOutlet var txtViewTranscription: UITextView!
    @IBOutlet var btnRecord: UIButton!
    @IBAction func btnRecordPressed(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest.endAudio()
            recognitionTask.cancel()
            
            btnRecord.setTitle("Record", for: [])
        } else {
            btnRecord.setTitle("Stop", for: [])
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSessionCategoryRecord)
                try audioSession.setMode(AVAudioSessionModeMeasurement)
                try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
                
                
                if let inputNode = audioEngine.inputNode {
                    recognitionRequest.shouldReportPartialResults = true
                    recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                        if let result = result {
                            self.txtViewTranscription.text = result.bestTranscription.formattedString
                            if result.isFinal {
                                self.audioEngine.stop()
                                inputNode.removeTap(onBus: 0)
                                self.btnRecord.setTitle("Record", for: [])
                            }
                        }
                    })
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    inputNode.removeTap(onBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer, when) in
                        self.recognitionRequest.append(buffer)
                    })
                
                    audioEngine.prepare()
                    try audioEngine.start()
                }
            } catch {
            //error handling
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speechRecognizer.delegate = self
        
        btnRecord.isEnabled = false
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                    case .authorized:
                        self.btnRecord.isEnabled = true
                    case .denied:
                        self.btnRecord.isEnabled = false
                        self.btnRecord.setTitle("Access Denied", for: .disabled)
                    case .restricted:
                        self.btnRecord.isEnabled = false
                        self.btnRecord.setTitle("Access Restricted", for: .disabled)
                    case .notDetermined:
                        self.btnRecord.isEnabled = false
                        self.btnRecord.setTitle("Not Authorized Yet", for: .disabled)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

