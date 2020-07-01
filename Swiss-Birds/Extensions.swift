//
//  Extensions.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import UIKit

extension String {


    /// Matches string with a regular expression, returning an array of `String`
    ///
    ///     html.matches(regex: "http(s)://.*/([a-z0-9]+).jpg")
    ///
    /// - Parameter regex: Regular expression to be matched
    /// - Parameter options: options passed to `NSRegularExpression`
    /// - Returns: Array with all matches and regexp groups
    func matches(regex: String, options: NSRegularExpression.Options = []) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: options) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        return matches.reduce([]) { res, match in
            var newRes = res
            for i in 0..<match.numberOfRanges {
                let x = String(self[Range(match.range(at: i), in: self)!])
                newRes.append(x)
            }
            return newRes
        }
    }
}
