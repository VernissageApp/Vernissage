//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

public extension [Status] {
    func getStatusesWithImagesOnly() -> [Status] {
        return self.filter { status in
            status.statusContainsImage()
        }
    }
}

public extension Status {
    func statusContainsImage() -> Bool {
        return getAllImageMediaAttachments().isEmpty == false
    }
    
    func statusContainsAltText() -> Bool {
        let mediaAttachments = self.getAllImageMediaAttachments()
        return mediaAttachments.contains(where: { $0.description?.isEmpty == false  })
    }

    func getAllImageMediaAttachments() -> [MediaAttachment] {
        if let reblog = self.reblog {
            // If status is rebloged the we have to check if orginal status contains image.
            return reblog.mediaAttachments
                .filter { mediaAttachment in mediaAttachment.type == .image }
        }

        return self.mediaAttachments
            .filter { mediaAttachment in mediaAttachment.type == .image }
    }
}
