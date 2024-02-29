//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Ильяс Жанаев on 13.02.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
    case resultTooLarge
    case resultTooSmall
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Decimal, _ number2: Decimal) throws -> Decimal {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Decimal)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    var calculationHistory: [CalculationHistoryItem] = []
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        guard let labelText = label.text, labelText.count < 18 else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle,
            let buttonOpearation = Operation(rawValue: buttonText)
        else { return }
        
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.decimalValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOpearation))
        
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetLabelText()
    }
    
    let maxResult: Decimal = 999999999999999999
    let minResult: Decimal = -99999999999999999
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.decimalValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            guard result >= minResult else {
                throw CalculationError.resultTooSmall
            }
            
            guard result <= maxResult else {
                throw CalculationError.resultTooLarge
            }
            
            let scientificFormatter = NumberFormatter()
            
            scientificFormatter.numberStyle = .scientific
            
            let resultString = numberFormatter.string(from: result as NSNumber)
            
            label.text = resultString
            
        } catch CalculationError.resultTooLarge {
            label.text = "Result too large"
        } catch CalculationError.resultTooSmall {
            label.text = "Result too small"
        } catch {
            label.text = "Error"
        }
        
        
        calculationHistory.removeAll()
    }
    
    @IBOutlet weak var label: UILabel!
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_Ru")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetLabelText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.result = label.text
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    func calculate() throws -> Decimal {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetLabelText() {
        label.text = "0"
    }
}

