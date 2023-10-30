//
//  SendDestinationView.swift
//  Send
//
//  Created by Andrey Chukavin on 30.10.2023.
//

import SwiftUI

struct SendDestinationView: View {
    let namespace: Namespace.ID
    let viewModel: SendDestinationViewModel

    var body: some View {
        VStack {
            VStack {
                TextField("Enter addr3ess", text: viewModel.destination)
                    .keyboardType(.decimalPad)
            }
            .padding()
            .border(Color.purple, width: 5)
            .matchedGeometryEffect(id: "dest", in: namespace)

            Lorem()
            
            Spacer()

            Button(action: {}, label: {
                Text("set")
            })
        }
        .padding(.horizontal)
    }
}

// #Preview {
//    SendDestinationView()
// }
