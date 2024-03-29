//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit
import ClientKit
import ServicesKit
import Nuke
import OSLog
import EnvironmentKit
import Semaphore
import UserNotifications

/// Service responsible for managing notifications.
@MainActor
public class NotificationsService {
    public static let shared = NotificationsService()
    private init() { }
    
    private let semaphore = AsyncSemaphore(value: 1)
    
    public func newNotificationsHasBeenAdded(for account: AccountModel, modelContext: ModelContext) async -> Bool {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accessToken = account.accessToken else {
            return false
        }
     
        // Get maximimum downloaded stauts id.
        guard let lastSeenNotificationId = self.getLastSeenNotificationId(accountId: account.id, modelContext: modelContext)  else {
            return false
        }
        
        let client = PixelfedClient(baseURL: account.serverUrl).getAuthenticated(token: accessToken)
        
        do {
            let linkableNotifications = try await client.notifications(minId: lastSeenNotificationId, limit: 5)
            return linkableNotifications.data.first(where: { $0.id != lastSeenNotificationId }) != nil
        } catch {
            ErrorService.shared.handle(error, message: "notifications.error.loadingNotificationsFailed")
            return false
        }
    }
    
    public func amountOfNewNotifications(modelContext: ModelContext) async -> Int {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        guard let accountData = AccountDataHandler.shared.getCurrentAccountData(modelContext: modelContext) else {
            return 0
        }
        
        guard let accessToken = accountData.accessToken else {
            return 0
        }
                
        // Get maximimum downloaded stauts id.
        guard let lastSeenNotificationId = self.getLastSeenNotificationId(accountId: accountData.id, modelContext: modelContext)  else {
            return 0
        }
        
        let client = PixelfedClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        var notifications: [PixelfedKit.Notification] = []
        var maxId: String? = nil
        var allItemsProcessed = false
        
        // There can be more then 40 newest notifications, that's why we have to sometimes send more then one request.
        while true {
            do {
                let linkable = try await client.notifications(maxId: maxId, limit: 40)
                guard linkable.data.first != nil else {
                    break
                }
                
                for item in linkable.data {
                    // We have to stop when we go to already seen notification.
                    if item.id == lastSeenNotificationId {
                        allItemsProcessed = true
                        break
                    }
                    
                    notifications.append(item)
                    
                    // We have to stop when we already count 99 notifications (it's maximum number which we want to show in the badge).
                    if notifications.count == 99 {
                        allItemsProcessed = true
                        break
                    }
                }
                
                if allItemsProcessed {
                    break
                }
                
                guard let linkedMaxId = linkable.link?.maxId else {
                    break
                }
                
                maxId = linkedMaxId
            } catch {
                ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadingNewStatuses")
                break
            }
        }
        
        // Return number of new notifications not visible yet on the timeline.
        return notifications.count
    }
    
    /// Function sets application badge counts when notifications (and badge) are enabled.
    public func setBadgeCount(_ count: Int, modelContext: ModelContext) async throws {
        // Badge have to enabled in system settings.
        let applicationSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)
        guard applicationSettings.showApplicationBadge else {
            return
        }
        
        // Notifications have to be enabled.
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else {
            return
        }

        // Badge notification have to be enabled.
        if settings.badgeSetting == .enabled {
            try await center.setBadgeCount(count)
        }
    }
    
    private func getLastSeenNotificationId(accountId: String, modelContext: ModelContext) -> String? {
        let accountData = AccountDataHandler.shared.getAccountData(accountId: accountId, modelContext: modelContext)
        return accountData?.lastSeenNotificationId
    }
}
