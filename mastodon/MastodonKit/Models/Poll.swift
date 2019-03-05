//
//  Poll.swift
//  mastodon
//
//  Created by Shihab Mehboob on 04/03/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation

public class Poll: Codable {
    /// The poll ID.
    public let id: String
    /// Poll expired?
    public let expired: Bool
    /// The time the poll expires.
    public let expiresAt: Date?
    /// Poll count.
    public let multiple: Bool
    /// The poll vote count.
    public let votesCount: Int
    /// Voted?
    public let voted: Bool?
    /// Options.
    public let options: PollOptions
    
    private enum CodingKeys: String, CodingKey {
        case id
        case expired
        case expiresAt = "expires_at"
        case multiple
        case votesCount = "votes_count"
        case voted
        case options
    }
}

public class PollOptions: Codable {
    /// The poll title.
    public let title: String
    /// Poll votes count.
    public let votesCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case title
        case votesCount = "votes_count"
    }
}

extension Poll: Equatable {}

public func ==(lhs: Poll, rhs: Poll) -> Bool {
    let areEqual = lhs.id == rhs.id &&
        lhs.id == rhs.id
    
    return areEqual
}
