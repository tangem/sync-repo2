//
//  NavigationLink+EmptyLabel.swift
//  Tangem Tap
//
//  Created by Andrew Son on 17/11/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import SwiftUI

extension NavigationLink where Label == EmptyView, Destination: View {
	
	init(destination: Destination, isActive: Binding<Bool>) {
		self.init(
			destination: destination,
			isActive: isActive,
			label: {
				EmptyView()
			})
	}

}
