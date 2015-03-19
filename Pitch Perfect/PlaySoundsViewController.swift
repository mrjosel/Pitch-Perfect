//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Brian Josel on 3/6/15.
//  Copyright (c) 2015 Brian Josel. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer:AVAudioPlayer!                  //audioPlayer for simple playback
    var audioEngine:AVAudioEngine!                  //audioEngine for playback with effects
    var receivedAudio:RecordedAudio!                //recordedAudio from last scene
    var audioFile:AVAudioFile!                      //above audio to be converted to file for use in audioEngine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Create audioEngine and audioFile for playback from URL for AVAudioUnit effects
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathURL, error: nil)
        
        //Load recorded file from RecordSoundsViewController into audioPlayer for simple playback at different rates
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.enableRate = true //enabling playback rate change
    }
    
    override func viewWillDisappear(animated: Bool) {
        //When back button is hit to segue back to RecordSoundsViewController, removes file from Documents directory to prevent from creating too many files
        //Savings files in /tmp is also possible, however this method prevents the app from ever running without a saved file
        stopPlayback()      //stops all playback prior to deleting file
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var fileName = receivedAudio.filePathURL.lastPathComponent as String!
        var fullFilePath = paths.stringByAppendingPathComponent(fileName)
        NSFileManager.defaultManager().removeItemAtPath(fullFilePath, error: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopPlayback() {
        //stops all playback
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playback(rate: Float) {
        //stops audio, resets to beginning of file, reveals label, plays audio at rate @rate - for simple playback
        stopPlayback()
        audioPlayer.rate = rate
        audioPlayer.delegate = self
        audioPlayer.currentTime = 0
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        //Plays back audio by augmenting pitch by rate
        //Function outside of button to allow use by multiple buttons
        
        //stop and reset all playback functions
        stopPlayback()
        
        //used for playing back sound
        var playerNode = AVAudioPlayerNode()
        audioEngine.attachNode(playerNode)

        //creating new pitch changing object
        var audioTimePitch = AVAudioUnitTimePitch()
        audioTimePitch.pitch = pitch            //default is 1.0.  Range is -2400 to 2400
        audioEngine.attachNode(audioTimePitch)
        
        //connecting playerNode and audioTimePitch to audioEngine, and connecting engine to output node (speakers)
        audioEngine.connect(playerNode, to: audioTimePitch, format: nil)
        audioEngine.connect(audioTimePitch, to: audioEngine.outputNode, format: nil)
        playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        //playback
        audioEngine.startAndReturnError(nil)
        playerNode.play()
    }
    
    func playAudioWithVariableDelay(delay: NSTimeInterval) {
        //Plays back audio with delay
        
        //stop and reset all playback functions
        stopPlayback()
        
        //used for playing back sound
        var playerNode = AVAudioPlayerNode()
        audioEngine.attachNode(playerNode)
        
        //creating new pitch changing object
        var audioDelay = AVAudioUnitDelay()
        audioDelay.delayTime = delay           //default is 1.0.  Range is 0.0 to 2.0
        audioEngine.attachNode(audioDelay)
        
        //connecting playerNode and audioTimePitch to audioEngine, and connecting engine to output node (speakers)
        audioEngine.connect(playerNode, to: audioDelay, format: nil)
        audioEngine.connect(audioDelay, to: audioEngine.outputNode, format: nil)
        playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        //playback
        audioEngine.startAndReturnError(nil)
        playerNode.play()
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        //Plays back audio slooooooowly using rate = 0.5
        playback(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        //Plays back audio quickly using rate = 2.0
        playback(2.0)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        //Plays audio back with chipmunk voice effect
        playAudioWithVariablePitch(1200)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        //Plays audio back with darth vader voice effect
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playDelayAudio(sender: UIButton) {
        //Plays audio back with delay
        playAudioWithVariableDelay(0.5)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        //stops audioPlay and stops/resets audioEngine
        stopPlayback()
    }
    
}
