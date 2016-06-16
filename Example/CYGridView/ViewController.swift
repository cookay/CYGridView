//
//  ViewController.swift
//  CYGridView
//
//  Created by cookay on 06/16/2016.
//  Copyright (c) 2016 cookay. All rights reserved.
//

import UIKit
import CYGridView

class ViewController: UIViewController {
    
    // MARK: - Properties
    var gridView: CYGridView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initGridView()
        
        self.colorSingleBoxes()
        self.colorMultiBoxes()
    }
    
    // MARK: - Init Views
    func initGridView() {
        self.gridView = CYGridView(frame: self.view.bounds, contentInsets: UIEdgeInsetsMake(10, 20, 30, 40), vBoxSpace: 10, hBoxSpace: 20, vBoxCount: 10, hBoxCount: 5)
        self.view.addSubview(self.gridView)
        
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[grid]-|", options: [NSLayoutFormatOptions(rawValue: 0)], metrics: nil, views: ["grid" : self.gridView])
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[grid]-|", options: [NSLayoutFormatOptions(rawValue: 0)], metrics: nil, views: ["grid" : self.gridView]))
        //self.gridView.addConstraints(constraints)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func colorSingleBoxes() {
        for x in 0..<self.gridView.hBoxCount {
            for y in 0..<self.gridView.vBoxCount {
                let box = UILabel(frame: CGRectZero)
                box.backgroundColor = UIColor.orangeColor()
                box.text = "\(x), \(y)"
                box.textAlignment = .Center
                self.gridView.addManaged(view: box, from: NSIndexPath(forX: x, forY: y))
            }
        }
    }
    
    func colorMultiBoxes() {
        do {
            let box = UIView(frame: CGRectZero)
            box.backgroundColor = UIColor.blueColor()
            self.gridView.addManaged(view: box, from: NSIndexPath(forX: 0, forY: 0), to: NSIndexPath(forX: 0, forY: 3))
        }
        
        do {
            let box = UIView(frame: CGRectZero)
            box.backgroundColor = UIColor.blueColor()
            self.gridView.addManaged(view: box, from: NSIndexPath(forX: 1, forY: 1), to: NSIndexPath(forX: 2, forY: 2))
        }
        
        do {
            let box = UIView(frame: CGRectZero)
            box.backgroundColor = UIColor.blueColor()
            self.gridView.addManaged(view: box, from: NSIndexPath(forX: 1, forY: 5), to: NSIndexPath(forX: 4, forY: 7))
        }
    }
}

