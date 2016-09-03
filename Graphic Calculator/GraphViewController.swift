 //
 //  GraphViewController.swift
 //  CalculatorV2
 //
 //  Created by fred on 19/08/16.
 //  Copyright © 2016 fred. All rights reserved.
 //
 
 import UIKit
 import Foundation
 
 class GraphViewController: UIViewController, GraphViewDataSourceFunction
 {
    
    // MARK: Property List
    private let userDefaults = UserDefaults.standard
    
    private func getGraphSettings() {
        if let savedOrigin = userDefaults.object(forKey: "Origin") as? String {
            CalculatorGraphView.axesCenter = CGPointFromString(savedOrigin)
        }
        if let savedScale = userDefaults.object(forKey: "Scale") as? CGFloat {
            CalculatorGraphView.graphScaleFactor = savedScale
        }
    }
    
    private func setGraphSettings() {
        let originToSave = NSStringFromCGPoint(CalculatorGraphView.axesCenter)
        userDefaults.set(originToSave, forKey: "Origin")
        let scaleToSave = Double(CalculatorGraphView.graphScaleFactor)
        userDefaults.set(scaleToSave, forKey: "Scale")
        userDefaults.synchronize()
    }
    
    private var brain = CalculatorBrain()
    
    // MARK: Model
    
    typealias PropertyList = AnyObject
    
    var graphProgram: PropertyList? = nil {
        didSet {
            if graphProgram != nil {
                brain.program = graphProgram!
                updateUI()
            }
        }
    }
    
    // MARK: View
    
    @IBOutlet weak var CalculatorGraphView: GraphView! {
        didSet {
            CalculatorGraphView.dataSourceFunction = self
            CalculatorGraphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: CalculatorGraphView,
                action: #selector(CalculatorGraphView.zoomsTheEntireGraph(_:))
            ))
            
            CalculatorGraphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: CalculatorGraphView,
                action: #selector(CalculatorGraphView.movesTheEntireGraph(_:))
            ))
            
            CalculatorGraphView.addGestureRecognizer(UITapGestureRecognizer(
                target: CalculatorGraphView,
                action: #selector(CalculatorGraphView.movesTheOriginOfTheGraph(_:))
            ))
            updateUI()
        }
    }
    
    internal func calculateYforX(sender: GraphView, x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        return CGFloat(brain.result)
    }
    
    private func updateUI() {
        if CalculatorGraphView != nil {
            self.getGraphSettings()
            CalculatorGraphView.setNeedsDisplay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userDefaults.object(forKey: "Origin") == nil {
            CalculatorGraphView.axesCenter = CalculatorGraphView.convert(CalculatorGraphView.center, from: CalculatorGraphView.superview)
        }
        savedBounds = view.bounds.size
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setGraphSettings()
    }
    
    // MARK: GraphCenter calculation when bonds change
    
    var coordinatesRelatedToCenter: CGPoint? = nil
    var savedBounds: CGSize? = nil
    
    override func viewWillLayoutSubviews() {
        if savedBounds == view.bounds.size {
            coordinatesRelatedToCenter = CGPoint(x: CalculatorGraphView.axesCenter.x-view.bounds.midX,y : CalculatorGraphView.axesCenter.y-view.bounds.midY)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if savedBounds != view.bounds.size  && coordinatesRelatedToCenter != nil {
            savedBounds = view.bounds.size
            CalculatorGraphView.axesCenter = CGPoint(x: view.bounds.midX + coordinatesRelatedToCenter!.x,y: view.bounds.midY + coordinatesRelatedToCenter!.y)
            coordinatesRelatedToCenter = nil
        }
    }
 }
