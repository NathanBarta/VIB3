//
//  SidebarTabViewController.swift
//  VIB3
//
//  Created by Nathan Barta on 9/27/20.
//  Copyright © 2020 Corectic. All rights reserved.
//

import Foundation
import Cocoa

class SidebarTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.loadView()
        self.awakeFromNib()

    }
    
    override var representedObject: Any? {
         didSet {
         // Update the view, if already loaded.
         }
     }
}
