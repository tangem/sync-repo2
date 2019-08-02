//
//  CardDetailsViewModel.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 31.07.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import UIKit

class CardDetailsViewModel: NSObject {
    
    // MARK: Image Views
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    // MARK: Labels
    
    @IBOutlet weak var balanceLabel: UILabel! {
        didSet {
            balanceLabel.font = UIFont.tgm_maaxFontWith(size: 24, weight: .medium)
        }
    }
    @IBOutlet weak var balanceVerificationLabel: UILabel! {
        didSet {
            balanceVerificationLabel.font = UIFont.tgm_maaxFontWith(size: 14, weight: .medium)
        }
    }
    
    @IBOutlet weak var walletBlockchainLabel: UILabel! {
        didSet {
            walletBlockchainLabel.font = UIFont.tgm_maaxFontWith(size: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var doubleScanHintLabel: UILabel! {
        didSet {
            doubleScanHintLabel.font = UIFont.tgm_maaxFontWith(size: 17, weight: .medium)
            doubleScanHintLabel.textColor = UIColor.tgm_red()
        }
    }
    //    @IBOutlet weak var networkSafetyDescriptionLabel: UILabel! {
//        didSet {
//            networkSafetyDescriptionLabel.font = UIFont.tgm_maaxFontWith(size: 12)
//        }
//    }
    
    @IBOutlet weak var walletAddressLabel: UILabel! {
        didSet {
            walletAddressLabel.font = UIFont.tgm_maaxFontWith(size: 14, weight: .medium)
        }
    }
    
    // MARK: Buttons
    
    @IBOutlet weak var buttonsAvailabilityView: UIView!
    
    @IBOutlet weak var loadButton: UIButton! {
        didSet {
            loadButton.layer.cornerRadius = 30.0
            loadButton.titleLabel?.font = UIFont.tgm_sairaFontWith(size: 20, weight: .bold)
            
            loadButton.layer.shadowRadius = 5.0
            loadButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            loadButton.layer.shadowColor = UIColor.black.cgColor
            loadButton.layer.shadowOpacity = 0.08
        }
    }
    
    @IBOutlet weak var extractButton: UIButton! {
        didSet {
            extractButton.layer.cornerRadius = 30.0
            extractButton.titleLabel?.font = UIFont.tgm_sairaFontWith(size: 20, weight: .bold)
            
            extractButton.layer.shadowRadius = 5.0
            extractButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            extractButton.layer.shadowColor = UIColor.black.cgColor
            extractButton.layer.shadowOpacity = 0.08
        }
    }
    
    @IBOutlet weak var scanButton: UIButton! {
        didSet {
            scanButton.titleLabel?.font = UIFont.tgm_maaxFontWith(size: 16, weight: .medium)
        }
    }
    
    @IBOutlet weak var moreButton: UIButton! {
        didSet {
            moreButton.titleLabel?.font = UIFont.tgm_maaxFontWith(size: 16, weight: .medium)
            moreButton.setTitleColor(UIColor.lightGray, for: .disabled)
        }
    }
    
    @IBOutlet weak var exploreButton: UIButton! {
        didSet {
            exploreButton.titleLabel?.font = UIFont.tgm_sairaFontWith(size: 20, weight: .bold)
            exploreButton.setTitleColor(UIColor.lightGray, for: .disabled)
        }
    }
    
    @IBOutlet weak var copyButton: UIButton! {
        didSet {
            copyButton.titleLabel?.font = UIFont.tgm_sairaFontWith(size: 20, weight: .bold)
            copyButton.setTitleColor(UIColor.lightGray, for: .disabled)
        }
    }
    
    // MARK: Other
    
    @IBOutlet weak var balanceVerificationActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cardWalletInfoView: UIView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBalance))
            tapRecognizer.numberOfTapsRequired = 1
            cardWalletInfoView.addGestureRecognizer(tapRecognizer)
        }
    }
    @IBOutlet weak var cardWalletInfoLoadingView: UIView!
    @IBOutlet weak var qrCodeContainerView: UIView!
    
    @objc func didTapBalance() {
       onBalanceTap?()
    }
    
    public var onBalanceTap: (() -> Void)?
}

extension CardDetailsViewModel {
    
    func setSubstitutionInfoLoading(_ isLoading: Bool) {
        cardImageView.isHidden = isLoading
    }
    
    func setWalletInfoLoading(_ loading: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.cardWalletInfoView.isHidden = loading
            self.cardWalletInfoLoadingView.isHidden = !loading
            self.buttonsAvailabilityView.isHidden = !loading
        }
    }
    
    func updateWalletAddress(_ text: String) {
        let paragraphStyle = paragraphStyleWith(lineSpacingChange: 5.0)
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.paragraphStyle : paragraphStyle,
                                                                           NSAttributedStringKey.kern : 0.88])
        walletAddressLabel.attributedText = attributedText
    }
    
    func updateWalletBalanceIsBeingVerified() {
        let text = "Verifying in blockchain..."
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.kern : 0.88,
                                                                           NSAttributedStringKey.foregroundColor : UIColor.black])
        balanceVerificationLabel.attributedText = attributedText
    }
    
    func updateWalletBalanceVerification(_ verified: Bool, customText: String? = nil) {
        var text = verified ? "Verified balance" : "Unverified balance"
        if let customText = customText, !customText.isEmpty {
            text = customText
        }
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.kern : 0.88,
                                                                           NSAttributedStringKey.foregroundColor : verified ? UIColor.tgm_green() : UIColor.tgm_red()])
        balanceVerificationLabel.attributedText = attributedText
    }
    
    func updateWalletBalanceNoWallet() {
        let string = "This card has no wallet.\nWallet creation is not available on the iPhone at this time"
        let attributedText = NSAttributedString(string: string, attributes: [NSAttributedStringKey.kern : 0.88,
                                                                             NSAttributedStringKey.foregroundColor : UIColor.tgm_red()])
        balanceVerificationLabel.attributedText = attributedText
    }
    
    func updateWalletBalance(title: String, subtitle: String? = nil) {
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.kern : 0.3])

        if let subtitle = subtitle {
            let subtitleAttributedString = NSAttributedString(string: subtitle, 
                                                              attributes: [NSAttributedStringKey.font : UIFont.tgm_maaxFontWith(size: 14, weight: .medium)])
            attributedText.append(subtitleAttributedString)
        }        
        
        balanceLabel.attributedText = attributedText
    }
    
    func updateBlockchainName(_ text: String) {
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.kern : 0.88])
        walletBlockchainLabel.attributedText = attributedText
    }
    
    private func paragraphStyleWith(lineSpacingChange: CGFloat, alignment: NSTextAlignment = .center) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing += lineSpacingChange
        paragraphStyle.alignment = alignment
        
        return paragraphStyle
    }
}
