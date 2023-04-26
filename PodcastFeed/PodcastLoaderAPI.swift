//
//  PodcastLoaderAPI.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
import SwiftyJSON
public class PodcastLoaderAPI: PodcastLoader{
    private let client: PodcastClient
  
    public init(client: PodcastClient) {
        self.client = client
    }
    public func load(completion: @escaping (PodcastLoaderResult) -> Void)
    {
        client.getPodcasts{ result in
            switch result{
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                let arrayPodcasts = Item(json: data).arrayPodcasts
                completion(.success(arrayPodcasts))
            }
            
        }
    }
}
