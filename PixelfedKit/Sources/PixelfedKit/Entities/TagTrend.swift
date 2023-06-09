//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Information about trending hashtag.
public struct TagTrend: Codable {

    /// Id number of tag.
    public let id: Int

    /// The value of the hashtag.
    public let name: String

    /// The value of the hashtag after the # sign.
    public let hashtag: String

    /// A link to the hashtag on the instance.
    public let url: String?

    /// Total uses of hashtag.
    public let total: Int
}
