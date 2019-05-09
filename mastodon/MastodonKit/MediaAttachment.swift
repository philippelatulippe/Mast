//
//  MediaAttachment.swift
//  MastodonKit
//
//  Created by Ornithologist Coder on 5/9/17.
//  Copyright © 2017 MastodonKit. All rights reserved.
//

import Foundation

public enum MediaAttachment {
    /// JPEG (Joint Photographic Experts Group) image
    case jpeg(Data?)
    /// GIF (Graphics Interchange Format) image
    case gif(Data?)
    /// PNG (Portable Network Graphics) image
    case png(Data?)
    /// Other media file
    case other(Data?, fileExtension: String, mimeType: String)
}

extension MediaAttachment {
    var data: Data? {
        switch self {
        case .jpeg(let data): return data
        case .gif(let data): return data
        case .png(let data): return data
        case .other(let data, _, _): return data
        }
    }

    var fileName: String {
        if StoreStruct.medType == 0 {
            switch self {
            case .jpeg: return "file.jpeg"
            case .gif: return "file.gif"
            case .png: return "file.png"
            case .other(_, let fileExtension, _): return "file.\(fileExtension)"
            }
        } else if StoreStruct.medType == 1 {
            switch self {
            case .jpeg: return "avatar.jpeg"
            case .gif: return "avatar.gif"
            case .png: return "avatar.png"
            case .other(_, let fileExtension, _): return "avatar.\(fileExtension)"
            }
        } else {
            switch self {
            case .jpeg: return "header.jpeg"
            case .gif: return "header.gif"
            case .png: return "header.png"
            case .other(_, let fileExtension, _): return "header.\(fileExtension)"
            }
        }
    }

    var mimeType: String {
        switch self {
        case .jpeg: return "image/jpg"
        case .gif: return "image/gif"
        case .png: return "image/png"
        case .other(_, _, let mimeType): return mimeType
        }
    }

    var base64EncondedString: String? {
        return data.map { "data:" + mimeType + ";base64," + $0.base64EncodedString() }
    }
}
