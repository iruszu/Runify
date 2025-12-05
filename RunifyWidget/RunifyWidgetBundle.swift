//
//  RunifyWidgetBundle.swift
//  RunifyWidget
//
//  Created by Kellie Ho on 2025-12-05.
//

import WidgetKit
import SwiftUI

@main
struct RunifyWidgetBundle: WidgetBundle {
    var body: some Widget {
        RunifyWidget()
        RunifyWidgetControl()
        RunifyWidgetLiveActivity()
    }
}
