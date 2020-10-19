//
//  PlayerViewController.swift
//  VIB3
//
//  Created by Nathan Barta on 9/25/20.
//  Copyright © 2020 Corectic. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

protocol PlayerControl: AnyObject {
    func setSongCoverArt(image: NSImage)
}

class PlayerViewController: NSViewController, PlayerControl {
    
    var isFileSelected: Bool = false
    var songName: String?
    
    @IBOutlet weak var songCoverArt: NSImageView!
    @IBOutlet weak var queueTableView: NSTableView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var skipForwardButton: NSButton!
    @IBOutlet weak var queueScrollView: NSScrollView!
    
    
    var urlsInQueue: [URL]?
    
    weak var playerDelegate: AudioPlaybackControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true //Gives mask to bounds settiings and such
        self.view.layer?.masksToBounds = true
        self.view.layer?.cornerRadius = 45
        self.view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.view.setValue(NSColor.gray, forKey: "backgroundColor")
        
//        playButton.wantsLayer = true
//        playButton.layer?.masksToBounds = true
//        playButton.layer?.cornerRadius = 26
////        playButton.layer?.backgroundColor = (NSColor.darkGray as! CGColor)
//
//        skipForwardButton.wantsLayer = true
//        skipForwardButton.layer?.masksToBounds = true
//        skipForwardButton.layer?.cornerRadius = 26
////        skipForwardButton.layer?.backgroundColor = (NSColor.darkGray as! CGColor)
        
        queueTableView.delegate = self
        queueTableView.dataSource = self
        
        queueScrollView.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func playPause(_ sender: Any) {
//        playerDelegate?.playPause()
        
        isFileSelected ? playerDelegate?.playPause() : selectFile(isFileSelected) //Do notif later
    }
    
    @IBAction func skipTrack(_ sender: Any) {
        playerDelegate?.skipTrack()
    }
    
    func setSongCoverArt(image: NSImage) {
        songCoverArt.image = image
    }
    
    @IBAction func viewQueue(_ sender: Any) {
        queueScrollView.isHidden = !queueScrollView.isHidden
    }
    
    @IBAction func selectFile(_ sender: Any) {
        
        songCoverArt.image = NSImage(named: "audioPlaceholder")
        
        guard let urlSelect = NSOpenPanel().selectUrls else { return }
        
//        let playerItem: AVPlayerItem = (AVPlayerItem(url: urlSelect[0]))
//        let playerItemMetaData: [AVMetadataItem] = playerItem.asset.metadata
//
//        for mItem in playerItemMetaData {
//            guard let key = mItem.commonKey?.rawValue, let value = mItem.value else{
//                continue
//            }
//
//            switch key {
////            case "title" : songName = value as? String ?? urlSelect?.lastPathComponent
////                print("value \(value)")
////                case "artist": artistLabel.text = value as? String
//            case "artwork" where value is Data : songCoverArt.image = NSImage(data: value as! Data)
//            default: continue
//            }
//        }
        
        isFileSelected = true
        urlsInQueue = urlSelect
        queueTableView.reloadData()
        playerDelegate?.newSelection(url: urlsInQueue!)
    }
    
//    var eqViewController: EQViewController!
//    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//
//        if let eqVC = segue.destinationController as? EQViewController, segue.identifier == "eqSegue" {
//            eqViewController = eqVC
//        }
//        self.playerDelegate = eqViewController
//        print(eqViewController)
//    }
}

extension PlayerViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return urlsInQueue?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = urlsInQueue![row]
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "songQueueColumn"), owner: nil) as? NSTableCellView
        cell!.textField?.stringValue = item.lastPathComponent
            
        return cell
    }
}
