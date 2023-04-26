//
//  Podcast.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation

public struct Root: Decodable{
    public let podcasts: [Podcast]
}
public struct Podcast: Equatable{
    public init(id: Int, title: String, author: String, description: String, imageURL: URL) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.imageURL = imageURL
    }
    
    public let id: Int
    public let title: String
    public let author: String
    public let description: String
    public let imageURL: URL
    
    
}

extension Podcast: Decodable{
    private enum CodingKeys: String, CodingKey{
        case id
        case title
        case author = "publisher"
        case description
        case imageURL = "image"
    }
}

public enum PodcastLoaderResult{
    case success([Podcast])
    case failure(Error)
}

public protocol PodcastLoader{
    func load(completion: @escaping (PodcastLoaderResult) -> Void)
}
