//
//  TangemBlogUrlBuilder.swift
//  Tangem
//
//  Created by Andrey Chukavin on 26.02.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

struct TangemBlogUrlBuilder {
    func postUrl(path: String) -> URL {
        let currentLanguageCode = Locale.current.languageCode ?? "en"

        let languageCode: String
        switch currentLanguageCode {
        case "ru":
            languageCode = currentLanguageCode
        default:
            languageCode = "en"
        }
        return URL(string: "https://tangem.com/\(languageCode)/blog/post/\(path)/")!
    }
}
