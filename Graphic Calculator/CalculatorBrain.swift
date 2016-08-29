//
//  CalculatorBrain.swift
//  CalculatorV2
//
//  Created by fred on 08/08/16.
//  Copyright © 2016 fred. All rights reserved.
//

import Foundation

func random(min: Double, max: Double) -> Double {
    return (Double(arc4random()) / Double(UINT32_MAX)) * (max - min) + min
}


class CalculatorBrain {
    
    private var accumulator = 0.0
    private var accumulatorDescription = " "
    private var internalProgram = [AnyObject]()
    private var internalVariableValue = 0.0
    private var internalError: String?
    private let formatter = NumberFormatter()
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            if isPartialResult {
                return pending!.binaryFunctionDescription(pending!.firstOperandDescription,
                                                    pending!.firstOperandDescription != accumulatorDescription ? accumulatorDescription : "")
            } else {
                return accumulatorDescription
            }
        }
    }
    
    var errorReported: String {
        get {
            return internalError ?? ""
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    // MARK: - Main brain functions
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, description:(String) -> String, errorCheck: ((Double) -> Bool)?)
        case BinaryOperation((Double,Double) -> Double, description:((String,String)) -> String, errorCheck: ((Double) -> Bool)?)
        case RandomNumber
        case Equals
    }

    private var operations: [String:Operation] = [
        
        "Rand": Operation.RandomNumber,
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±": Operation.UnaryOperation({-$0}, description: {"±" + "(" + $0 + ")"}, errorCheck: nil),
        "%": Operation.UnaryOperation({$0/100}, description: {"(" + $0 + ")%"}, errorCheck: nil),
        "√": Operation.UnaryOperation(sqrt, description: {"√" + "(" + $0 + ")"},errorCheck: {$0>0}),
        "cos": Operation.UnaryOperation(cos, description: {"cos" + "(" + $0 + ")"},errorCheck: nil),
        "sin": Operation.UnaryOperation(sin, description: {"sin" + "(" + $0 + ")"},errorCheck: nil),
        "log": Operation.UnaryOperation(log, description: {"log" + "(" + $0 + ")"},errorCheck: nil),
        "tan": Operation.UnaryOperation(tan, description: {"tan" + "(" + $0 + ")"},errorCheck: nil),
        "+": Operation.BinaryOperation({$0+$1}, description: { $0 + "+" +  $1},errorCheck: nil),
        "−": Operation.BinaryOperation({$0-$1}, description: {$0 + "−" +  $1},errorCheck: nil),
        "×": Operation.BinaryOperation({$0*$1}, description: {$0 + "×" +  $1},errorCheck: nil),
        "÷": Operation.BinaryOperation({$0/$1}, description: {$0 + "÷" +  $1},errorCheck: {(($0 > 0) || ($0 < 0))}),
        "=": Operation.Equals
    ]
    
    private var provisoryConstantDescription:String?
    private var performOperationDescription:String?
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            internalError = nil
            internalProgram.append(symbol as AnyObject)
            switch operation {
            case .Constant(let value):
                accumulator = value
                accumulatorDescription = symbol
            case .UnaryOperation(let function, let descriptionFunction, let errorFunction):
                accumulatorDescription =  descriptionFunction(accumulatorDescription)
                accumulator = function(accumulator)
                launchErrorDetection(operation: symbol, guardBoolean: errorFunction, firstOperand: accumulator, secondOperand: nil)
            case .BinaryOperation(let function, let descriptionFunction, let errorFunction):
                executePendingBinaryOperation()
                //accumulatorDescription = accumulatorDescription
                pending = PendingBinaryOperationInfo(binaryFunction: function, binaryFunctionDescription: descriptionFunction, firstOperand: accumulator, firstOperandDescription: accumulatorDescription, binaryFunctionSymbol: symbol, errorBooleanFunction: errorFunction)
                                case .Equals:
                executePendingBinaryOperation()
            case .RandomNumber:
                accumulator = random(min: 0.0, max: 1.0)
                accumulatorDescription = String(format:"%g",accumulator)
            }
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var binaryFunctionDescription: (String,String) -> String
        var firstOperand: Double
        var firstOperandDescription: String
        var binaryFunctionSymbol: String
        var errorBooleanFunction: ((Double) -> Bool)?
    }
    

    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulatorDescription = pending!.binaryFunctionDescription(pending!.firstOperandDescription, accumulatorDescription)
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            launchErrorDetection(operation: pending!.binaryFunctionSymbol, guardBoolean: pending!.errorBooleanFunction, firstOperand: accumulator, secondOperand: accumulator)
            pending = nil
        }
    }
    
    
    func setOperand(VariableName: String) {
        internalVariableValue = variableValues[VariableName] ?? 0.0
        accumulator = internalVariableValue
        internalProgram.append(VariableName as AnyObject)
        accumulatorDescription = VariableName
        }

    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        accumulatorDescription = String(format:"%g",operand)
    }
    
    
    var variableValues: [String:Double] = [:] {
        didSet {
            if let lastinternalProgramValue = internalProgram.last as? String {
                if let lastThingDoneByTheBrain = operations[lastinternalProgramValue]  {
                    switch lastThingDoneByTheBrain {
                    case .Constant:
                        undoLastThingDoneInTheBrain()
                    default:
                        break
                    }
                }
            }
            program = internalProgram as PropertyList
        }
    }
    
    func clearAllTheBrain() {
        clear()
        variableValues = [:]
    }

    // MARK: - Error detection
    private enum CalculatorBrainError: Error {
        case SquareRootOfaNegativeNumber
        case DivideByZero
        
        var description: String {
            switch self {
            case .SquareRootOfaNegativeNumber: return "SquareRootOfaNegativeNumber"
            case .DivideByZero: return "DivideByZero"
            }
        }
    }
    
    private func detectErrors(unaryBinaryOperation: String, guardBoolean: ((Double) -> Bool)?, firstOperand: Double, secondOperand: Double?) throws {
        
        if let operationErrorCheckBoolean = guardBoolean?(firstOperand) {
            guard ((unaryBinaryOperation != "÷") || operationErrorCheckBoolean) else {
                throw CalculatorBrainError.DivideByZero
            }
            guard ((unaryBinaryOperation != "√") || operationErrorCheckBoolean) else {
                throw CalculatorBrainError.SquareRootOfaNegativeNumber
            }
        }
    }
    
    private func launchErrorDetection(operation: String, guardBoolean: ((Double) -> Bool)?=nil, firstOperand: Double, secondOperand: Double?) {
        do {
            try detectErrors(unaryBinaryOperation: operation, guardBoolean: guardBoolean, firstOperand: firstOperand, secondOperand: secondOperand)}
        catch CalculatorBrainError.DivideByZero { internalError = CalculatorBrainError.DivideByZero.description}
        catch CalculatorBrainError.SquareRootOfaNegativeNumber { internalError = CalculatorBrainError.SquareRootOfaNegativeNumber.description }
        catch {internalError = "Unknown"}
    }
    
    private func undoLastThingDoneInTheBrain() {
        internalProgram.removeLast()
    }
    
    // MARK: -  Operation program - save all user operation history
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if operations[op as! String] != nil {
                        performOperation(symbol: op as! String)
                    } else {
                        setOperand(VariableName: op as! String)
                    }
                  }
                }
            }
        }
    }

    private func clear() {
        accumulator = 0.0
        accumulatorDescription = " "
        internalVariableValue = 0.0
        pending = nil
        internalProgram.removeAll()
        internalError = nil
    }
}
