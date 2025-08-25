//
//  TabView.swift
//  Runify
//
//  Created by Kellie Ho on 2025-08-18.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Image(systemName: "house")
                }
            
        }
    }
}

#Preview {
    MainTabView()
}
