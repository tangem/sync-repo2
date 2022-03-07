//
//  BackupStoryPage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 14.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct BackupStoryPage: View {
    @Binding var progress: Double
    let scanCard: (() -> Void)
    let orderCard: (() -> Void)
    
    var body: some View {
        VStack {
            StoriesTangemLogo()
                .padding()
            
            Text("story_backup_title")
                .font(.system(size: 36, weight: .semibold))
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("story_backup_description")
                .font(.system(size: 24))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
            
            
            GeometryReader { geometry in
                Color.clear
                    .background(
                        // Bottom card
                        Image("wallet_card")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 0.7 * geometry.size.width)
                            .rotation3DEffect(.degrees(-40), axis: (0.2, 0.1, 0.4), perspective: 0)
                            .offset(x: 0.2 * geometry.size.width, y: 0.25 * geometry.size.width)
                            .modifier(AnimatableOffsetModifier(progress: progress, speed: 30, direction: CGPoint(x: -1.0, y: -1.0)))
                    )
                    .background(
                        // Top left
                        Image("wallet_card")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 0.65 * geometry.size.width)
                            .rotation3DEffect(.degrees(50), axis: (0.15, 0.3, 0.4), perspective: 0)
                            .offset(x: -0.4 * geometry.size.width, y: -0.15 * geometry.size.width)
                            .modifier(AnimatableOffsetModifier(progress: progress, speed: 20, direction: CGPoint(x: 1.0, y: 0.5)))
                    )
                    .background(
                        // Top right
                        Image("wallet_card")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 0.5 * geometry.size.width)
                            .rotation3DEffect(.degrees(50), axis: (0.9, 0.0, -0.5), perspective: 0)
                            .offset(x: 0.3 * geometry.size.width, y: -0.3 * geometry.size.width)
                            .modifier(AnimatableOffsetModifier(progress: progress, speed: 10, direction: CGPoint(x: -1.0, y: -0.5)))
                    )
                    .background(
                        Image("cards_flying")
                            .resizable()
                            .frame(width: geometry.size.width)
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.3)
                        ,
                        alignment: .center
                    )
            }
            
            Spacer()
            
            StoriesBottomButtons(scanColorStyle: .grayAlt2, orderColorStyle: .black, scanCard: scanCard, orderCard: orderCard)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(Color("tangem_story_background").edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

fileprivate extension AnimatableOffsetModifier {
    init(progress: Double, speed: Double, direction: CGPoint) {
        self.progress = progress
        self.start = 0
        self.end = 1
        self.curveX = {
            speed * direction.x * $0
        }
        self.curveY = {
            speed * direction.y * $0
        }
    }
}

struct BackupStoryPage_Previews: PreviewProvider {
    static var previews: some View {
        BackupStoryPage(progress: .constant(1)) { } orderCard: { }
        .previewGroup(devices: [.iPhone7, .iPhone12ProMax], withZoomed: false)
    }
}
