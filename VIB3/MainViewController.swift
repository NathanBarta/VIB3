//
//  MainViewController.swift
//  VIB3
//
//  Created by Nathan Barta on 9/22/20.
//  Copyright © 2020 Corectic. All rights reserved.
//

import Foundation
import Cocoa

class MainViewController: NSViewController {
    
    var playerViewController: PlayerViewController!
    var eqViewController: EQViewController!
    
    @IBOutlet weak var tabView: NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPanels()
        
        tabView.drawsBackground = false
        tabView.tabViewBorderType = .none
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadPanels() {
        
        let playerPanel = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "playerViewController") as PlayerViewController
        let playerPanel1 = NSStoryboard(name: "Main", bundle: nil).instantiateController(identifier: "playerViewController") as PlayerViewController
        
        tabView.addTabViewItem(NSTabViewItem(viewController: playerPanel))
        tabView.addTabViewItem(NSTabViewItem(viewController: playerPanel1))
        
        
        self.playerViewController = playerPanel
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {

        if let eqVC = segue.destinationController as? EQViewController, segue.identifier == "eqSegue" {
            self.eqViewController = eqVC
        } else { print ("error eqVC") }

        playerViewController.playerDelegate = eqViewController
        eqViewController.toPlayerDelegate = playerViewController
    }
}
