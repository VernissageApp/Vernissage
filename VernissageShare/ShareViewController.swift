//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import UIKit
import Social
import ClientKit
import EnvironmentKit
import SwiftData

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            return
        }

        guard let attachments = item.attachments else {
            return
        }

        // Create shared objects.
        let applicationState = ApplicationState.shared
        let client = Client.shared

        // Get curret signed in user.
        let modelContext = SwiftDataHandler.shared.sharedModelContainer.mainContext
        guard let currentAccount = AccountDataHandler.shared.getCurrentAccountData(modelContext: modelContext) else {
            return
        }

        // Create Pixelfed client.
        let accountModel = currentAccount.toAccountModel()
        client.setAccount(account: accountModel)

        // Set application state (with default instance settings).
        applicationState.changeApplicationState(accountModel: accountModel,
                                                instance: nil,
                                                lastSeenStatusId: accountModel.lastSeenStatusId,
                                                lastSeenNotificationId: accountModel.lastSeenNotificationId)

        // Update application settings from database.
        ApplicationSettingsHandler.shared.update(applicationState: applicationState, modelContext: modelContext)

        // Create view.
        let view = ComposeView(attachments: attachments)
            .environment(applicationState)
            .environment(client)
            .tint(applicationState.tintColor.color())

        // Add view to current UIViewController.
        let childView = UIHostingController(rootView: view)
        addChild(childView)

        childView.view.frame = self.view.bounds
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            childView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            childView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        NotificationCenter.default.addObserver(forName: NotificationsName.shareSheetClose, object: nil, queue: nil) { _ in
            self.close()
        }
    }

    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
