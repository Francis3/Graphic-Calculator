//
//  ViewController.swift
//  CalculatorV2
//
//  Created by fred on 08/08/16.
//  Copyright © 2016 fred. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    @IBOutlet weak var displayDescription: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBOutlet private weak var display: UILabel! {
        didSet {
            initFormatter()
        }
    }
    
    private let formatter = NumberFormatter()
    
    private func initFormatter() {
        formatter.usesSignificantDigits = true
        formatter.maximumFractionDigits = 6
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
            display.text = textCurrentlyInDisplay == "" ? "0" : textCurrentlyInDisplay
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + (((digit == "." && textCurrentlyInDisplay.range(of: ".") == nil) || digit != ".") ? digit : "")
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    // MARK: - -->M button
    @IBAction func setvariableM(_ sender: UIButton) {
        brain.variableValues["M"] = displayValue
        displayValue = brain.result
        userIsInTheMiddleOfTyping  = false
    }
    
    // MARK: - M button
    @IBAction func getVariableM(_ sender: UIButton) {
       // if let variableUsed = sender.currentTitle {
            brain.setOperand(VariableName: sender.currentTitle!) 
            displayValue = brain.result
        //}
    }
    
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            display.text = formatter.string(from: NSNumber(value: newValue!))
        }
    }
    @IBAction func clearEverything() {
        brain.clearAllTheBrain()
        displayValue = brain.result
        displayDescription.text = brain.description
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping  = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        displayDescription.text = brain.description + (brain.isPartialResult ? " ..." : " =")
        //just to test the error mesages reported by the brain
        print("Brain Error: \(brain.errorReported)")
    }
}

