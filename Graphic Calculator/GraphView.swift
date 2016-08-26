//
//  GraphView.swift
//  CalculatorV2
//
//  Created by fred on 19/08/16.
//  Copyright © 2016 fred. All rights reserved.
//

import UIKit

//@IBDesignable
class GraphView: UIView
{

    private var axes = AxesDrawer()
    
    //@IBInspectable
    var graphScaleFactor: CGFloat = 50 { didSet { setNeedsDisplay()}}
    //@IBInspectable
    var axesCenter: CGPoint = CGPoint(x: 0,y :0) { didSet { setNeedsDisplay()}}
    
    //private let originalCenter = convert(center, from: superview)
    
    // MARK: - Main draw function
    
    override func draw(_ rect: CGRect) {
        
        axes.drawAxesInRect(bounds: bounds, origin: axesCenter, pointsPerUnit: graphScaleFactor)
        
    }
    
    
    // MARK: - Gesture handling API
    
    func zoomsTheEntireGraph(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            graphScaleFactor *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    func movesTheEntireGraph(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            let translation = recognizer.translation(in: self)
            axesCenter = CGPoint(x: translation.x+axesCenter.x, y: translation.y+axesCenter.y)
            recognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    func movesTheOriginOfTheGraph(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            break
        case .ended:
            let location = recognizer.location(in: self)
            axesCenter = CGPoint(x: location.x, y: location.y)
            //recognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }


}
