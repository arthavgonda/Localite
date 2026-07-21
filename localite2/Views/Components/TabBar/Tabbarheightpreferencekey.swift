//
//  Tabbarheightpreferencekey.swift
//  localite2
//
//  Created by ANOOP on 20/07/26.
//

import SwiftUI

struct TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
