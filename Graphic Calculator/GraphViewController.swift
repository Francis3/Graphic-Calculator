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
    
    //var variableValues: [String:Double] = [:]
    
    private var brain = CalculatorBrain()
    
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
            CalculatorGraphView.setNeedsDisplay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CalculatorGraphView.axesCenter = CalculatorGraphView.convert(CalculatorGraphView.center, from: CalculatorGraphView.superview)
    }
}
