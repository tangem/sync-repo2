//
//  TestCardParsingCapable.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 29.09.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import UIKit

protocol TestCardParsingCapable {
    func launchSimulationParsingOperationWith(payload: Data)
}

extension TestCardParsingCapable where Self: UIViewController {
    
    func showSimulationSheet() {
        let alertController = UIAlertController.testDataAlertController { (testData) in
            self.launchSimulationParsingOperationWith(payload: Data(testData.rawValue.asciiHexToData()!))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
