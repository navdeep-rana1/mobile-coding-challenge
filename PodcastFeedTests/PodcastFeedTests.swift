//
//  PodcastFeedTests.swift
//  PodcastFeedTests
//
//  Created by Nav on 26/04/23.
//

import XCTest
import PodcastAPI

class PodcastLoaderAPI{
    private let client: PodcastClient
    
    
    init(client: PodcastClient) {
        self.client = client
    }
    var loadCallCount = 0
    func load(completion: @escaping (PodcastApiError?) -> Void){
        loadCallCount += 1
        client.getPodcasts{ error in
            if error != nil{
                completion(error)
            }
        }
    }
}

class PodcastClient{
    var getPodcastCallCount = 0
    var arrayCompletions = [(PodcastApiError?) -> Void]()
    
    func getPodcasts(completion: @escaping (PodcastApiError?) -> Void){
        getPodcastCallCount += 1
        arrayCompletions.append(completion)
        
    }
    
    func completes(with error: PodcastApiError, at index: Int = 0){
        arrayCompletions[index](error)
    }
}
final class PodcastFeedTests: XCTestCase {

   func test_init_doesnotRequestPodcastsFromBackend()
    {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.loadCallCount, 0)
        
    }
    
    func test_load_callsGetFromPodcastAPIClient(){
        let (sut, client) = makeSUT()
        sut.load(){ _ in}
        XCTAssertEqual(client.getPodcastCallCount, 1)
    }
    
    func test_load_failsWithConnectivityErrorOnClientFailsWithConnectionError(){
        let (sut, client) = makeSUT()
        var receivedError: PodcastApiError?
        sut.load{ receivedError = $0 }
        client.completes(with: PodcastApiError.apiConnectionError)
        XCTAssertEqual(receivedError, .apiConnectionError)
    }
    
    private func makeSUT() -> (PodcastLoaderAPI, PodcastClient){
        let client = PodcastClient()
        let sut = PodcastLoaderAPI(client: client)
        return (sut, client)
    }

    private func anyError() -> NSError{
        NSError(domain: "Any podcast error", code: 10)
    }
}
