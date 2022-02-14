//
//  BackupStoryPage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 14.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct BackupStoryPage: View {
    var body: some View {
        VStack {
            Text("story_backup_title")
                .multilineTextAlignment(.center)
            
            Text("story_backup_description")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Spacer()
            

            Image("cards_flying")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            
            HStack {
                Text("Scan Card")
                
                Text("Order Card")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BackupStoryPage_Previews: PreviewProvider {
    static var previews: some View {
        BackupStoryPage()
    }
}
