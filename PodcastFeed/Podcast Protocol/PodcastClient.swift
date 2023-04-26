//
//  PodcastClient.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
import PodcastAPI

public enum PodcastResult{
    case success(Data)
    case failure(PodcastApiError)
}

public protocol PodcastClient{
    typealias Result = PodcastResult
    func getPodcasts(completion: @escaping (Result) -> Void)

}
