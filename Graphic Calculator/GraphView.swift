//
//  GraphView.swift
//  CalculatorV2
//
//  Created by fred on 19/08/16.
//  Copyright © 2016 fred. All rights reserved.
//

import UIKit


protocol GraphViewDataSourceFunction: class {
    func calculateYforX(sender: GraphView, x: CGFloat) -> CGFloat?
}

//bug with Version 8.0 beta 6 (8S201h) when using IBDesignable for the view -> build loop
//@IBDesignable
class GraphView: UIView
{
    private struct Constants {
        static let xIncrementSize: CGFloat = 1
    }
    
    weak var dataSourceFunction:GraphViewDataSourceFunction?
    
    private var color = UIColor.black
    
    //@IBInspectable
    private var graphScaleFactor: CGFloat = 50 { didSet { setNeedsDisplay()}}
    //@IBInspectable
    var axesCenter: CGPoint = CGPoint(x: 0,y :0) { didSet { setNeedsDisplay()}}
    
    // MARK: - Main draw function
    
    internal override func draw(_ rect: CGRect) {
        let axes = AxesDrawer()
        axes.drawAxesInRect(bounds: bounds, origin: axesCenter, pointsPerUnit: graphScaleFactor)
        if dataSourceFunction != nil  {
            self.drawFunctionInRect(bounds: bounds, origin: axesCenter, pointsPerUnit: graphScaleFactor)
        }
    }
    
    // MARK: - Function drawing
    
    private func drawFunctionInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        UIGraphicsGetCurrentContext()!.saveGState()
        color.set()
        let path = UIBezierPath()
        var xToDraw =  bounds.minX
        var firstDrawPoint = true
        while xToDraw <= bounds.maxX {
            let xBrain = changeToBrainCoordinate(xToDraw: xToDraw, origin: origin, pointsPerUnit: pointsPerUnit)
            if let yBrain = dataSourceFunction?.calculateYforX(sender: self, x: xBrain) {
                if yBrain.isNormal || yBrain.isZero {
                    let yToDraw = changeToCoordinateToDraw(y: yBrain, origin: origin, pointsPerUnit: pointsPerUnit)
                    if yToDraw <= bounds.maxY && yToDraw >= bounds.minY {
                        if firstDrawPoint {
                            path.move(to: CGPoint(x: xToDraw, y: align(coordinate: yToDraw)))
                            firstDrawPoint = false
                        } else {
                            path.addLine(to: CGPoint(x: xToDraw, y: align(coordinate: yToDraw)))
                        }
                    }
                }
            }
            xToDraw += Constants.xIncrementSize
        }
        path.stroke()
        UIGraphicsGetCurrentContext()!.restoreGState()
    }
    
    private func changeToBrainCoordinate(xToDraw: CGFloat, origin: CGPoint, pointsPerUnit: CGFloat) -> CGFloat {
        return (xToDraw - origin.x) / pointsPerUnit
    }
    
    private func changeToCoordinateToDraw(y: CGFloat, origin: CGPoint, pointsPerUnit: CGFloat) -> CGFloat {
        return -((y * pointsPerUnit) - origin.y)
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
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
        default:
            break
        }
    }
}
