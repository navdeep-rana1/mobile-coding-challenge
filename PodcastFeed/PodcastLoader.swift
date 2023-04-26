//
//  Podcast.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
import PodcastAPI
public enum PodcastLoaderResult{
    case success([Podcast])
    case failure(PodcastApiError)
}

public protocol PodcastLoader{
    func load(completion: @escaping (PodcastLoaderResult) -> Void)
}
