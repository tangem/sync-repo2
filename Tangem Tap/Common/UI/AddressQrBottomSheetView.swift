//
//  AddressQrBottomSheetView.swift
//  Tangem Tap
//
//  Created by Andrew Son on 12.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine

struct AddressQrBottomSheetView: View {
    
    var isPresented: Binding<Bool>
    var shareAddress: String
    var address: String
    
    @State private var backgroundOpacity: Double = 0
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var lastDragValue: DragGesture.Value?
    
    private let backgroundVisibleOpacity: Double = 0.5
    private let sheetVisibleOffset: CGFloat = 0
    private let sheetSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 570)
    private let defaultAnimDuration: Double = 0.22
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    private func speed(for value: DragGesture.Value) -> Double {
        guard let lastDragValue = lastDragValue else { return 0 }
        
        let timeDiff = value.time.timeIntervalSince(lastDragValue.time)
        let speed: Double = Double(value.location.y - lastDragValue.location.y) / timeDiff
        
        return speed
    }
    
    private func hideBottomSheet(safeAreaBottomInset: CGFloat) {
        withAnimation(.linear(duration: defaultAnimDuration)) {
            sheetOffset = sheetSize.height + safeAreaBottomInset
            backgroundOpacity = 0
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let dragGesture = DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    lastDragValue = value
                    let currentDistanceToBottomEdge = screenSize.height - value.location.y
                    let startDisctanceToBottomEdge = screenSize.height - value.startLocation.y
                    backgroundOpacity = min(backgroundVisibleOpacity, backgroundVisibleOpacity * Double(currentDistanceToBottomEdge / startDisctanceToBottomEdge))
                    sheetOffset = max(0, value.translation.height)
                }
                .onEnded { value in
                    let shouldDismiss = value.predictedEndTranslation.height > UIScreen.main.bounds.height / 3
                    let speed: Double = speed(for: value)
                    
                    if(speed > 200) || shouldDismiss {
                        let distanceToBottomEdge = (screenSize.height - value.location.y)
                        let animDuration = min(defaultAnimDuration, Double(distanceToBottomEdge) / speed)
                        withAnimation(.linear(duration: animDuration)) {
                            sheetOffset = sheetSize.height + proxy.safeAreaInsets.bottom
                            backgroundOpacity = 0
                        }
                    } else {
                        isPresented.wrappedValue = true
                    }
                }
            
            ZStack(alignment: .bottomLeading) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxHeight: UIScreen.main.bounds.height)
                    .opacity(backgroundOpacity)
                    .onTapGesture {
                        hideBottomSheet(safeAreaBottomInset: proxy.safeAreaInsets.bottom)
                    }
                VStack {
                    Rectangle()
                        .frame(size: .init(width: 33, height: 5))
                        .cornerRadius(2.5)
                        .padding(.top, 12)
                        .foregroundColor(.tangemTapGrayLight4)
                    Image(uiImage: QrCodeGenerator.generateQRCode(from: shareAddress))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(size: .init(width: 206, height: 206))
                        .padding(.top, 49)
                        .padding(.bottom, 30)
                    Text("address_qr_code_message")
                        .frame(maxWidth: 225)
                        .font(.system(size: 18, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.tangemTapGrayDark)
                    HStack(spacing: 10) {
                        Button(action: { UIPasteboard.general.string = address }, label: {
                            HStack {
                                Text(address)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: 100)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.tangemTapGrayDark6)
                                Image(systemName: "doc.on.clipboard")
                                    .foregroundColor(.tangemTapGreen)
                            }
                            .frame(height: 40)
                            .padding(.horizontal, 16)
                            .background(Color.tangemTapBgGray)
                            .cornerRadius(20)
                        })
                        Button(action: { showShareSheet() }, label: {
                            Image(systemName: "arrowshape.turn.up.right")
                                .frame(height: 40)
                                .foregroundColor(.tangemTapGreen)
                                .padding(.horizontal, 16)
                                .background(Color.tangemTapBgGray)
                                .cornerRadius(20)
                        })
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 50)
                    TangemButton(isLoading: false,
                                 title: "common_close",
                                 size: .wide) {
                        hideBottomSheet(safeAreaBottomInset: proxy.safeAreaInsets.bottom)
                    }
                    .buttonStyle(TangemButtonStyle(color: .grayAlt, font: .system(size: 18, weight: .semibold), isDisabled: false))
                    .padding(.bottom, 16 + proxy.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .gesture(dragGesture)
                .offset(x: 0, y: sheetOffset)
            }
            .frame(alignment: .bottom)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onReceive(Just(isPresented.wrappedValue), perform: { presented in
            if presented && sheetOffset > 0 {
                withAnimation(.linear(duration: defaultAnimDuration)) {
                    sheetOffset = 0
                    backgroundOpacity = backgroundVisibleOpacity
                }
                isPresented.wrappedValue = false
            }
        })
    }
    
    func showShareSheet() {
        let av = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

struct AddressQrBottomSheetPreviewView: View {
    
    @State var isPresentedBottomSheet: Bool = false
    
    var body: some View {
        ZStack {
            Button(action: {
                isPresentedBottomSheet.toggle()
            }, label: {
                Text("Show bottom sheet")
                    .padding()
            })
            AddressQrBottomSheetView(isPresented: $isPresentedBottomSheet, shareAddress: "eth:0x01232483902f903678a098bce", address: "0x01232483902f903678a098bce")
        }
        
    }
}

struct AddressQrBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddressQrBottomSheetPreviewView()
    }
}

extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}
