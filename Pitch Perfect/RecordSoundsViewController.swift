//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Brian Josel on 3/4/15.
//  Copyright (c) 2015 Brian Josel. All rights reserved.
//  

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    //View Controller for when user is recording voice
    
    ///set buttons and labels as outlets to allow for disabling, hiding, etc
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    //initialize audioRecorder and recordedAudio
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var paused = false                  //variable to know whether recording is paused or not

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true                //stop button is hidden at first view
        recordButton.enabled = true             //record button is enabled at first view
        recordButton.hidden = false
        recordingLabel.text = "Tap to Record"   //recordingLabel is visible, displays "Tap to Record"
        recordingLabel.hidden = false
        pauseButton.hidden = true
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        //Pressing button records audio until hitting stop button, reveals stop button, hides record button, reveals recording label
        
        //next state of buttons after recording has began
        stopButton.hidden = false
        recordButton.enabled = false
        pauseButton.hidden = false
        recordingLabel.text = "recording"       //text change to "recording" to denote recording in progress
        
        if !paused { //only carry out if not paused
            //sets the path as a String to the documents directory where audio is stored
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            
            //creates filename based on time and date (ensures no two files have the same name), finally creates NSURL with filename and path
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            
            //creates new session for recording using above filename
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            session.setActive(true, error: nil)

            
            //sets up recorder to save audio to NSURL path and filename, begins recording
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.record()
        } else { //only perform subset of above actions if recording is paused
            paused = false
            pauseButton.enabled = true
            recordButton.enabled = false
            audioRecorder.record()
        }
        

    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        //Pauses recording session, disables pause button, enables recording putton
        paused = true
        recordingLabel.text = "paused"
        pauseButton.enabled = false
        recordButton.enabled = true
        audioRecorder.pause()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) { //if successful, recordedAudio is saved and passed onto the next scene, segues to next scene
            recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Segues to next scene
        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        //stops recording, deactivates session, hides labels and disables buttons (for a cleaner visual transition)
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        recordingLabel.hidden = true
        stopButton.hidden = true
        pauseButton.hidden = true
        recordButton.hidden = true
    }
}