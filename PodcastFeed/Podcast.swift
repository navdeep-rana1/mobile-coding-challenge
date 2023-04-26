//
//  Podcast.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
struct Podcast{
    let title: String
    let author: String
    let description: String
    let imageURL: URL
}

enum PodcastLoaderResult{
    case success([Podcast])
    case failure(Error)
}

protocol PodcastLoader{
    func load(completion: @escaping (PodcastLoaderResult) -> Void)
}
