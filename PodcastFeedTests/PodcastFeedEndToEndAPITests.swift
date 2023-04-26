//
//  PodcastFeedTests.swift
//  PodcastFeedTests
//
//  Created by Nav on 26/04/23.
//

import XCTest
@testable import PodcastFeed
import PodcastAPI
import SwiftyJSON

final class PodcastFeedEndToEndAPITests: XCTestCase {

    
    func test_load_succeedsWithPodcastObjects(){
        let (sut, _) = makeSUT()
        let exp = expectation(description: "Wait for client to finish request")
        sut.load { result in
            switch result{
            case let .success(arrayPodcast):
                XCTAssertFalse(arrayPodcast.isEmpty)
                XCTAssertEqual(arrayPodcast[0].title, "Star Wars - The Force Awakens")
                XCTAssertEqual(arrayPodcast[0].publisher, "Matt Feury")
                XCTAssertEqual(arrayPodcast[1].title, "Star Wars Theory: The Great Star Wars Ice Cream Conspiracy")
                XCTAssertEqual(arrayPodcast[1].publisher, "J and Ben Carlin")
                
            case let .failure(error):
                XCTFail("Expected succesfull result, but got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
    
    private func makeSUT() -> (PodcastLoaderAPI, RemotePodcastClient){
        let client = RemotePodcastClient()
        let sut = PodcastLoaderAPI(client: client)
        return (sut, client)
    }

}
