//
//  GraphViewController.swift
//  CalculatorV2
//
//  Created by fred on 19/08/16.
//  Copyright © 2016 fred. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController
{

    @IBOutlet weak var CalculatorGraphView: GraphView! {
        didSet {
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
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        CalculatorGraphView.axesCenter = CalculatorGraphView.convert(CalculatorGraphView.center, from: CalculatorGraphView.superview)
    }


}
