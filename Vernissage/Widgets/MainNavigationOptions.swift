//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

struct MainNavigationOptions: View {
    let onViewModeIconTap: (MainView.ViewMode) -> Void

    @Binding var hiddenMenuItems: [MainView.ViewMode]

    init(hiddenMenuItems: Binding<[MainView.ViewMode]>, onViewModeIconTap: @escaping (MainView.ViewMode) -> Void) {
        self._hiddenMenuItems = hiddenMenuItems
        self.onViewModeIconTap = onViewModeIconTap
    }

    var body: some View {
        if !self.hiddenMenuItems.contains(where: { $0 == .home }) {
            Button {
                self.onViewModeIconTap(.home)
            } label: {
                HStack {
                    Text(MainView.ViewMode.home.title)
                    Image(systemName: MainView.ViewMode.home.image)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .local }) {
            Button {
                self.onViewModeIconTap(.local)
            } label: {
                HStack {
                    Text(MainView.ViewMode.local.title)
                    Image(systemName: MainView.ViewMode.local.image)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .federated }) {
            Button {
                self.onViewModeIconTap(.federated)
            } label: {
                HStack {
                    Text(MainView.ViewMode.federated.title)
                    Image(systemName: MainView.ViewMode.federated.image)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .search }) {
            Button {
                self.onViewModeIconTap(.search)
            } label: {
                HStack {
                    Text(MainView.ViewMode.search.title)
                    Image(systemName: MainView.ViewMode.search.image)
                }
            }
        }

        Divider()

        Menu {
            Button {
                self.onViewModeIconTap(.trendingPhotos)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingPhotos.title)
                    Image(systemName: MainView.ViewMode.trendingPhotos.image)
                }
            }

            Button {
                self.onViewModeIconTap(.trendingTags)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingTags.title)
                    Image(systemName: MainView.ViewMode.trendingTags.image)
                }
            }

            Button {
                self.onViewModeIconTap(.trendingAccounts)
            } label: {
                HStack {
                    Text(MainView.ViewMode.trendingAccounts.title)
                    Image(systemName: MainView.ViewMode.trendingAccounts.image)
                }
            }
        } label: {
            HStack {
                Text("mainview.tab.trending", comment: "Trending menu section")
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }

        Divider()

        if !self.hiddenMenuItems.contains(where: { $0 == .profile }) {
            Button {
                self.onViewModeIconTap(.profile)
            } label: {
                HStack {
                    Text(MainView.ViewMode.profile.title)
                    Image(systemName: MainView.ViewMode.profile.image)
                }
            }
        }

        if !self.hiddenMenuItems.contains(where: { $0 == .notifications }) {
            Button {
                self.onViewModeIconTap(.notifications)
            } label: {
                HStack {
                    Text(MainView.ViewMode.notifications.title)
                    Image(systemName: MainView.ViewMode.notifications.image)
                }
            }
        }
    }
}
