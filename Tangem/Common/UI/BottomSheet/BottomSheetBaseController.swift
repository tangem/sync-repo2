//
//  BottomSheetBaseController.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 17.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import UIKit

class BottomSheetBaseController: UIViewController {
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }

    var preferredSheetCornerRadius: CGFloat = 8 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    var preferredSheetBackgroundColor: UIColor = .label {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackgroundColor = preferredSheetBackgroundColor
        }
    }

    var tapOutsideToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapOutsideToDismissEnabled = tapOutsideToDismissEnabled
        }
    }

    var swipeDownToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.swipeDownToDismissEnabled = swipeDownToDismissEnabled
        }
    }

    var preferredContentBackgroundColor: UIColor = UIColor.white

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitionDelegate(
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetBackgroundColor: preferredSheetBackgroundColor
    )
}
