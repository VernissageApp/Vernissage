//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import WidgetKit
import SwiftUI
import Intents

struct PhotoProvider: TimelineProvider {
    typealias Entry = PhotoWidgetEntry

    func placeholder(in context: Context) -> PhotoWidgetEntry {
        StatusFetcher.shared.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (PhotoWidgetEntry) -> Void) {
        Task {
            if let widgetEntry = await self.getWidgetEntries(length: 1).first {
                completion(widgetEntry)
            } else {
                let entry = StatusFetcher.shared.placeholder()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let widgetEntries = await self.getWidgetEntries()

            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: widgetEntries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

    func getWidgetEntries(length: Int = 3) async -> [PhotoWidgetEntry] {
        do {
            return try await StatusFetcher.shared.fetchWidgetEntries(length: length)
        } catch {
            return [StatusFetcher.shared.placeholder()]
        }
    }
}
