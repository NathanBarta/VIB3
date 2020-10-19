//
//  EQViewController.swift
//  VIB3
//
//  Created by Nathan Barta on 9/22/20.
//  Copyright © 2020 Corectic. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AVFoundation
import MediaPlayer
import AudioUnit
import CoreAudio
import CoreAudioKit

protocol AudioPlaybackControl: AnyObject {
    func playPause()
    func newSelection(url: [URL])
    func skipTrack()
}

enum FreqStyle {
    case Americana
    case Eastern
    case Latin
}

class EQViewController: NSViewController, AVAudioPlayerDelegate, AudioPlaybackControl {

    var audioEngine: AVAudioEngine = AVAudioEngine()
    var equalizer: AVAudioUnitEQ! = AVAudioUnitEQ(numberOfBands: 9)
    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    let reverb = AVAudioUnitReverb()
    let echo = AVAudioUnitDelay()
    let distortion = AVAudioUnitDistortion()
    let pitchTime = AVAudioUnitTimePitch()
    let freqAmericana = [50,100,200,600,800,4000,5000,7000,10000]
    let freqEastern = [50,100,150,200,250,300,600,2000,4000]
    let freqLatin = [20,50,100,200,500,1000,2000,5000,10000]
    
    
    var freqStyle: FreqStyle = .Americana
    
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var toPlayerDelegate: PlayerControl?
    
    @IBOutlet weak var slider0: NSSlider!
    @IBOutlet weak var slider1: NSSlider!
    @IBOutlet weak var slider2: NSSlider!
    @IBOutlet weak var slider3: NSSlider!
    @IBOutlet weak var slider4: NSSlider!
    @IBOutlet weak var slider5: NSSlider!
    @IBOutlet weak var slider6: NSSlider!
    @IBOutlet weak var slider7: NSSlider!
    @IBOutlet weak var slider8: NSSlider!
    
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var echoDelayTimeSlider: NSSlider!
    @IBOutlet weak var echoWetDryMixSlider: NSSlider!
    @IBOutlet weak var distortionPreGainSlider: NSSlider!
    @IBOutlet weak var pitchSlider: NSSlider!
    
    @IBOutlet weak var reverbToggleSwitch: NSButton!
    @IBOutlet weak var echoToggleSwitch: NSButton!
    @IBOutlet weak var distortionToggleSwitch: NSButton!
    @IBOutlet weak var pitchToggleSwitch: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var volumeSeparator: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volumeSeparator.fillColor = NSColor.white
        volumeSeparator.borderColor = NSColor.white
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func gainChange(_ sender: NSSlider) {
        self.equalizer.bands[sender.tag].gain = sender.floatValue
    }
    
    @IBAction func volumeChange(_ sender: NSSlider) {
        self.equalizer.globalGain = sender.floatValue
    }
    
    @IBAction func reverbSliderChanged(_ sender: NSSlider) {
        self.reverb.wetDryMix = sender.floatValue
    }
    
    @IBAction func echoDelayTimeSliderChanged(_ sender: NSSlider) {
        self.echo.delayTime = TimeInterval(sender.floatValue)
    }
    
    @IBAction func echoWetDryMixSliderChanged(_ sender: NSSlider) {
        self.echo.wetDryMix = sender.floatValue
    }
    
    @IBAction func distortionPreGainSliderChanged(_ sender: NSSlider) {
        self.distortion.preGain = sender.floatValue
    }
    
    @IBAction func pitchSliderChanged(_ sender: NSSlider) {
        self.pitchTime.pitch = (sender.floatValue * 100.0)
    }
    
    @IBAction func toggleEQ(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.equalizer.bypass = false
        }
        else {
            self.equalizer.bypass = true
        }
    }
    
    @IBAction func toggleReverb(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.reverb.bypass = false
        }
        else {
            self.reverb.bypass = true
        }
    }
    
    @IBAction func toggleEcho(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.echo.bypass = false
        }
        else {
            self.echo.bypass = true
        }
    }
    
    @IBAction func toggleDistortion(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.distortion.bypass = false
        }
        else {
            self.distortion.bypass = true
        }
    }
    
    @IBAction func togglePitch(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            self.pitchTime.bypass = false
        }
        else {
            self.pitchTime.bypass = true
        }
    }
    
    @IBAction func resetEQSliders(_ sender: Any) {
        print("RESET EQ SLIDERS")
        
        defaultEQ()
        
        slider0.setValue(0.0, forKey: "floatValue")
        slider1.setValue(0.0, forKey: "floatValue")
        slider2.setValue(0.0, forKey: "floatValue")
        slider3.setValue(0.0, forKey: "floatValue")
        slider4.setValue(0.0, forKey: "floatValue")
        slider5.setValue(0.0, forKey: "floatValue")
        slider6.setValue(0.0, forKey: "floatValue")
        slider7.setValue(0.0, forKey: "floatValue")
        slider8.setValue(0.0, forKey: "floatValue")
        volumeSlider.setValue(0.0, forKey: "floatValue")
        
        //RESET EFFECTS
        reverbSlider.setValue(0.0, forKey: "floatValue")
        echoDelayTimeSlider.setValue(1, forKey: "floatValue")
        echoWetDryMixSlider.setValue(50.0, forKey: "floatValue")
        distortionPreGainSlider.setValue(0.0, forKey: "floatValue")
        pitchSlider.setValue(0.0, forKey: "floatValue")
        reverbToggleSwitch.state = NSControl.StateValue.off
        echoToggleSwitch.state = NSControl.StateValue.off
        distortionToggleSwitch.state = NSControl.StateValue.off
        pitchToggleSwitch.state = NSControl.StateValue.off
    }
    
    @IBAction func freqStyleChanged(_ sender: NSPopUpButton) {
        switch sender.indexOfSelectedItem {
            case 0: freqStyle = .Americana
            case 1: freqStyle = .Eastern
            case 2: freqStyle = .Latin
        default: break
        }
        //default eq with changes
        defaultEQ()
        resetEQSliders(true)
    }
    
    
    func defaultEQ() {
        print("DEFAULT EQ")
        let bands = equalizer.bands
        for i in 0...8 {
            switch freqStyle {
            case .Americana: bands[i].frequency = Float(freqAmericana[i])
            case .Eastern: bands[i].frequency = Float(freqEastern[i])
            case .Latin: bands[i].frequency = Float(freqLatin[i])
            }
            
            bands[i].bypass = false
            bands[i].filterType = .parametric
            bands[i].gain = 0.0
            bands[i].bandwidth = 0.7
            bands[i].bypass = false
        }
        self.equalizer.globalGain = 0.0
        
        self.reverb.bypass = true
        self.reverb.wetDryMix = 0.0
        self.echo.bypass = true
        self.echo.delayTime = TimeInterval(1)
        self.echo.wetDryMix = 50.0
        self.distortion.bypass = true
        self.distortion.preGain = 0.0
        self.pitchTime.bypass = true
        self.pitchTime.pitch = 0.0
        self.pitchTime.rate =  1.0
        self.pitchTime.overlap = 32.0
    }
    
    func setEQ(songName: String) { //Take in name, and if it exists, then load up the eq.
        
        var fetchedSong: SongEQPreset?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SongEQPreset")
        request.predicate = NSPredicate(format: "songID == %@", songName)
        
        do {
            let result = try context.fetch(request) as! [SongEQPreset]
            if result.count != 0 {
                fetchedSong = result[0]
            }
        }
        catch {
            print(error)
        }
        
        if fetchedSong != nil { //Set the EQ if the song has a preset. //MAUBE SET BANDS TOO
            slider0.setValue(fetchedSong?.band0, forKey: "floatValue")
            slider1.setValue(fetchedSong?.band1, forKey: "floatValue")
            slider2.setValue(fetchedSong?.band2, forKey: "floatValue")
            slider3.setValue(fetchedSong?.band3, forKey: "floatValue")
            slider4.setValue(fetchedSong?.band4, forKey: "floatValue")
            slider5.setValue(fetchedSong?.band5, forKey: "floatValue")
            slider6.setValue(fetchedSong?.band6, forKey: "floatValue")
            slider7.setValue(fetchedSong?.band7, forKey: "floatValue")
            slider8.setValue(fetchedSong?.band8, forKey: "floatValue")
            volumeSlider.setValue(fetchedSong?.volume, forKey: "floatValue")
            
            equalizer.bands[0].gain = fetchedSong!.band0
            equalizer.bands[1].gain = fetchedSong!.band1
            equalizer.bands[2].gain = fetchedSong!.band2
            equalizer.bands[3].gain = fetchedSong!.band3
            equalizer.bands[4].gain = fetchedSong!.band4
            equalizer.bands[5].gain = fetchedSong!.band5
            equalizer.bands[6].gain = fetchedSong!.band6
            equalizer.bands[7].gain = fetchedSong!.band7
            equalizer.bands[8].gain = fetchedSong!.band8
            
            equalizer.globalGain = fetchedSong!.volume
        }
    }
    
    func saveEQ(songName: String) { //If the eq is new, then create new object, else save edits
        
        var fetchedSong: SongEQPreset?
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SongEQPreset")
        request.predicate = NSPredicate(format: "songID == %@", songName)
        
        do {
             let result = try context.fetch(request) as! [SongEQPreset]
             if result.count != 0 {
                 fetchedSong = result[0]
             }
        }
        catch {
            print(error)
        }
        
       
        if fetchedSong == nil { //Create new songEQPreset
            
            print("New songEQPreset")
            
            let newSongEQPreset = NSEntityDescription.insertNewObject(forEntityName: "SongEQPreset", into: context)
            newSongEQPreset.setValue(songName, forKey: "songID")
            newSongEQPreset.setValue(volumeSlider.floatValue, forKey: "volume")
            newSongEQPreset.setValue(slider0.floatValue, forKey: "band0")
            newSongEQPreset.setValue(slider1.floatValue, forKey: "band1")
            newSongEQPreset.setValue(slider2.floatValue, forKey: "band2")
            newSongEQPreset.setValue(slider3.floatValue, forKey: "band3")
            newSongEQPreset.setValue(slider4.floatValue, forKey: "band4")
            newSongEQPreset.setValue(slider5.floatValue, forKey: "band5")
            newSongEQPreset.setValue(slider6.floatValue, forKey: "band6")
            newSongEQPreset.setValue(slider7.floatValue, forKey: "band7")
            newSongEQPreset.setValue(slider8.floatValue, forKey: "band8")
            
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
        else { //Save to songEQPreset
                let editSongEQPreset = self.context.object(with: fetchedSong!.objectID) as! SongEQPreset
            
                print("Edit songEQPreset")
            
                editSongEQPreset.setValue(songName, forKey: "songID")
                editSongEQPreset.setValue(self.volumeSlider.floatValue, forKey: "volume")
                editSongEQPreset.setValue(self.slider0.floatValue, forKey: "band0")
                editSongEQPreset.setValue(self.slider1.floatValue, forKey: "band1")
                editSongEQPreset.setValue(self.slider2.floatValue, forKey: "band2")
                editSongEQPreset.setValue(self.slider3.floatValue, forKey: "band3")
                editSongEQPreset.setValue(self.slider4.floatValue, forKey: "band4")
                editSongEQPreset.setValue(self.slider5.floatValue, forKey: "band5")
                editSongEQPreset.setValue(self.slider6.floatValue, forKey: "band6")
                editSongEQPreset.setValue(self.slider7.floatValue, forKey: "band7")
                editSongEQPreset.setValue(self.slider8.floatValue, forKey: "band8")
        }
    }
    
    var songPaths: [URL]? //Was going to do a queue but got tired and made this hacky thing.
    var songCounter: Int = -1
    
    func newSelection(url: [URL]) {
        songCounter = -1
        
        songPaths = url
        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }
        else {
            audioCompletion()
        }
    }
    
    func nextInQueue() {
        print("nextInQueue")
        if songCounter < songPaths!.count {
            self.defaultEQ()
            self.resetEQSliders(true)
            print("Starting new File: \(songPaths![songCounter].lastPathComponent)")
            startFile(url: songPaths![songCounter])
        }
        else {
            print("QUEUE OVER")
        }
    }
    
    //STARTS FILE BY URL. CALLED BY PLAYERVC.
    func startFile(url: URL) {
        
        setEQ(songName: url.lastPathComponent)
        
        //META DATA
        let playerItem: AVPlayerItem = (AVPlayerItem(url: url))
        let playerItemMetaData: [AVMetadataItem] = playerItem.asset.metadata
        
        for mItem in playerItemMetaData {
            guard let key = mItem.commonKey?.rawValue, let value = mItem.value else{
                continue
            }
            
            switch key {
                //            case "title" : songName = value as? String ?? urlSelect?.lastPathComponent
                //                print("value \(value)")
            //                case "artist": artistLabel.text = value as? String
            case "artwork" where value is Data : toPlayerDelegate!.setSongCoverArt(image: NSImage(data: value as! Data)!)
            default: continue
            }
            
        }
        
        
        
        //SONG LOADING
        do {
            let audioFile: AVAudioFile! = try AVAudioFile(forReading: url, commonFormat: .pcmFormatFloat32, interleaved: false)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            
            

            guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)  else{ return }
            
            do{
                audioFile.framePosition = 0
                try audioFile.read(into: audioFileBuffer)
            } catch{
                print("over")
            }
            
//            let ad = AVAudioFormat.init(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: true)
            
            audioEngine.attach(audioPlayerNode)
            audioEngine.attach(equalizer)
            audioEngine.attach(reverb)
            audioEngine.attach(echo)
            audioEngine.attach(pitchTime)
            audioEngine.attach(distortion)
            
            audioEngine.connect(audioPlayerNode, to: equalizer, format: audioFormat)
            audioEngine.connect(equalizer, to: reverb, format: audioFormat)
            audioEngine.connect(reverb, to: echo, format: audioFormat)
            audioEngine.connect(echo, to: pitchTime, format: audioFormat)
            audioEngine.connect(pitchTime, to: distortion, format: audioFormat)
            audioEngine.connect(distortion, to: audioEngine.outputNode, format: audioFormat)
            
            audioEngine.prepare()
            try audioEngine.start()
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: { self.audioCompletion(songName: url.lastPathComponent) })
            audioPlayerNode.prepare(withFrameCount: audioFrameCount)
            audioPlayerNode.play()
        }
        catch {
            print(error)
        }
//        if audioPlayerNode.isPlaying == false {
//            audioPlayerNode.play()
//        }
        audioPlayerNode.pause()
        audioPlayerNode.play()
    }
    
    func skipTrack() {
        if songPaths?.count != 0 && audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
//            audioCompletion() //OK SO audioPlayerNode calls the completion handler
        }
    }
    
    //PAUSES SONG IF IS PLAYING
    func playPause() {
        if audioPlayerNode.isPlaying == true { //Pause
            self.audioPlayerNode.pause()
            print("PAUSE")
        }
        else {
            self.audioPlayerNode.play()
            print("PLAY")
        }
    }
    
    //STOPS ALL AUDIO AND CALLS FOR SONG TO BE SAVED, AND CALLS QUEUE
    func audioCompletion(songName: String? = nil) {
//        print("AUDIO COMPLETION CALLED")
        
        songCounter += 1
        
        audioPlayerNode.reset()
        audioEngine.stop()
        audioEngine.reset()
        
        DispatchQueue.main.async {
            if songName != nil {
                self.saveEQ(songName: songName!)
            }
        }
        
        //*Waiting spinner or something
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextInQueue()
        }
    }
    
    @IBAction func printStuff(_ sender: Any) {
        print("Audio engine is running: \(audioEngine.isRunning)")
        print("Player node is playing: \(audioPlayerNode.isPlaying)")
        print("Engine Input node \(audioEngine.inputNode)")
        print("Engine Input node -> audioUnit \(String(describing: audioEngine.inputNode.audioUnit))")
    }
    
    
}

//Via: Leo Dabus on StackOverflow https://stackoverflow.com/questions/28008262/detailed-instruction-on-use-of-nsopenpanel
extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Audio File"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["mp3","wav","flac","acc","alac","aiff"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
    var selectUrls: [URL]? {
        title = "Select Audio Files"
        allowsMultipleSelection = true
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["mp3","wav","flac"] // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls : nil
    }
}
