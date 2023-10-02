//
//  ManageTokensBottomSheetIntermediateDisplayable.swift
//  Tangem
//
//  Created by Andrey Fedorov on 02.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

/// Represents an intermediate entity in the chain of Manage Tokens bottom sheet displayables.
protocol ManageTokensBottomSheetIntermediateDisplayable: ManageTokensBottomSheetDisplayable {
    /// Next chain member, up the chain.
    /* weak */ var nextManageTokensBottomSheetDisplayable: ManageTokensBottomSheetDisplayable? { get }
}
