//
//  PodcastFeedTests.swift
//  PodcastFeedTests
//
//  Created by Nav on 26/04/23.
//

import XCTest

class PodcastLoaderAPI{
    
    var loadCallCount = 0
    func load(){
        loadCallCount += 1
    }
}

final class PodcastFeedTests: XCTestCase {

   func test_init_doesnotRequestPodcastsFromBackend()
    {
        let sut = PodcastLoaderAPI()
        XCTAssertEqual(sut.loadCallCount, 0)
        
    }
    

}
