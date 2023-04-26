//
//  PodcastClient.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
import PodcastAPI
import SwiftyJSON

public enum PodcastClientResult{
    case success(JSON)
    case failure(PodcastApiError)
}

public protocol PodcastClient{
    func getPodcasts(completion: @escaping (PodcastClientResult) -> Void)

}
