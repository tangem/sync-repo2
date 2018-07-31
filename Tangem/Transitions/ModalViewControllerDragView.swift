//
//  ModalViewControllerDragView.swift
//  Haptic
//
//  Created by Gennady Berezovsky on 22.03.18.
//  Copyright © 2018 Gennady Berezovsky. All rights reserved.
//

import UIKit

class ModalViewControllerDragView: UIView {
    
    @IBOutlet weak var dragIndicatorView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let dragIndicatorView = self.dragIndicatorView {
            dragIndicatorView.layer.cornerRadius = dragIndicatorView.bounds.height / 2
            dragIndicatorView.backgroundColor = UIColor.darkGray
        }
    }
    
}
