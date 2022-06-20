//
//  CardOperationViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

class CardOperationViewModel: ObservableObject {
    @Published var error: AlertBinder? = nil
    @Published var isLoading: Bool = false
    @Published var dismissPublisher: Bool = false
    
    let title: String
    let buttonTitle: LocalizedStringKey
    let shouldPopToRoot: Bool
    let alert: String
    let actionButtonPressed: (_ completion: @escaping (Result<Void, Error>) -> Void) -> Void
    
    private unowned let coordinator: CardOperationRoutable
    
    internal init(title: String,
                  buttonTitle: LocalizedStringKey = "common_save_changes",
                  shouldPopToRoot: Bool = false,
                  alert: String,
                  actionButtonPressed: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void,
                  coordinator: CardOperationRoutable) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.shouldPopToRoot = shouldPopToRoot
        self.alert = alert
        self.actionButtonPressed = actionButtonPressed
        self.coordinator = coordinator
    }
    
    
    func onTap() {
        isLoading = true
        actionButtonPressed { [weak self] result in
            DispatchQueue.main.async {
                self?.handleCompletion(result)
            }
        }
    }
    
    private func handleCompletion(_ result: Result<Void, Error>) {
        isLoading = false
        
        switch result {
        case .success:
            if self.shouldPopToRoot {
                DispatchQueue.main.async {
                    self.popToRoot()
                }
            } else {
                dismissPublisher.toggle()
            }
        case .failure(let error):
            if case .userCancelled = error.toTangemSdkError() {
                return
            }
            
            self.error = error.alertBinder
        }
    }
}

//MARK: - Navigantion
extension CardOperationViewModel {
    func popToRoot() {
        coordinator.popToRoot()
    }
}
