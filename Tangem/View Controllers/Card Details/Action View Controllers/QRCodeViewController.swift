//
//  QRCodeViewController.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 02.09.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation
import QRCode
import TangemKit

class QRCodeViewController: ModalActionViewController {
    
    var cardDetails: Card?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let cardDetails = cardDetails else {
            assertionFailure()
            return
        }
        
        var qrCodeResult = QRCode(cardDetails.qrCodeAddress)
        qrCodeResult?.size = imageView.frame.size
        imageView.image = qrCodeResult?.image
        
        addressLabel.text = cardDetails.address
    }
}
