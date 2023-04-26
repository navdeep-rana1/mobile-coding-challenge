//
//  PodcastFeedTests.swift
//  PodcastFeedTests
//
//  Created by Nav on 26/04/23.
//

import XCTest

class PodcastLoaderAPI{
    private let client: PodcastClient
    
    enum Error{
        case noConnectivity
        case authenticationError
    }
    init(client: PodcastClient) {
        self.client = client
    }
    var loadCallCount = 0
    func load(completion: @escaping (Error?) -> Void){
        loadCallCount += 1
        client.getPodcasts{ error in
            if error != nil{
                completion(Error.noConnectivity)
            }
        }
    }
}

class PodcastClient{
    var getPodcastCallCount = 0
    var arrayCompletions = [(Error?) -> Void]()
    
    func getPodcasts(completion: @escaping (Error?) -> Void){
        getPodcastCallCount += 1
        arrayCompletions.append(completion)
        
    }
    
    func completes(with error: Error, at index: Int = 0){
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
        var receivedError: PodcastLoaderAPI.Error?
        sut.load{ receivedError = $0 }
        client.completes(with: anyError())
        XCTAssertEqual(receivedError, .noConnectivity)
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
