//
//  UIColor+Extenstion.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit

private enum FBColor: String {
    case B1
    case B2
    case B3
    case B4
    case B5
    case B6
}

extension UIColor {
    static let B1 = FBColor(.B1)
    static let B2 = FBColor(.B2)
    static let B3 = FBColor(.B3)
    static let B4 = FBColor(.B4)
    static let B5 = FBColor(.B5)
    static let B6 = FBColor(.B6)
    
    private static func FBColor(_ color: FBColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}
