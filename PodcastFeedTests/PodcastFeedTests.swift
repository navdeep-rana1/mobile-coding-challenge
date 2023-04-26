//
//  PodcastFeedTests.swift
//  PodcastFeedTests
//
//  Created by Nav on 26/04/23.
//

import XCTest
import Foundation
import PodcastAPI
import PodcastFeed

class PodcastLoaderAPI{
    private let client: PodcastClient
    
    enum Result{
        case success([Podcast])
        case failure(PodcastApiError)
    }
    init(client: PodcastClient) {
        self.client = client
    }
    var loadCallCount = 0
    func load(completion: @escaping (Result) -> Void){
        loadCallCount += 1
        client.getPodcasts{ result in
            switch result{
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                if let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.podcasts))
                }
            }
            
        }
    }
}


class PodcastClient{
    
    typealias Result = PodcastResult
    var getPodcastCallCount = 0
    var arrayCompletions = [(Result) -> Void]()
    
    enum PodcastResult{
        case success(Data)
        case failure(PodcastApiError)
    }
    
    func getPodcasts(completion: @escaping (Result) -> Void){
        getPodcastCallCount += 1
        arrayCompletions.append(completion)
    }
    
    func completes(with error: PodcastApiError, at index: Int = 0){
        arrayCompletions[index](.failure(error))
    }
    
    func completesWithData(_ data: Data, at index: Int = 0){
        arrayCompletions[index](.success(data))
    }
}
final class PodcastFeedTests: XCTestCase {

   func test_init_doesnotRequestPodcastsFromBackendOnCreation()
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
        sut.load{result in
            switch result{
            case let .failure(error):
                receivedError = error
            case .success(_):
                break
            }
        }
        client.completes(with: PodcastApiError.apiConnectionError)
        XCTAssertEqual(receivedError, .apiConnectionError)
    }

    
    func test_load_failsWithSameErrorAsClient(){
        let (sut, client) = makeSUT()
        let sampleErrors = [PodcastApiError.apiConnectionError, PodcastApiError.authenticationError, PodcastApiError.invalidRequestError, PodcastApiError.notFoundError, PodcastApiError.serverError, PodcastApiError.tooManyRequestsError]
        let exp = expectation(description: "wait for request to complete")
        exp.expectedFulfillmentCount = sampleErrors.count
        
        sampleErrors.enumerated().forEach{ index, element in
            sut.load{result in
                switch result{
                case let .failure(error as PodcastApiError?):
                    XCTAssertEqual(element, error)
                    exp.fulfill()

                case .success(_):
                    break
                }
                
            }
            client.completes(with: element, at: index)

        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_completesSuccesfullyWithPodcastsWhenClientCompletesWithData(){
        let (sut, client) = makeSUT()
        let podcast1 = makeAPodcast()
        let podcast2 = makeAPodcast()
        
        let exp = expectation(description: "wait for request")
        let podcastJson = ["podcasts": [["id": podcast1.id,
                                        "title": podcast1.title,
                                        "image": podcast1.imageURL.absoluteString,
                                        "description": podcast1.description,
                                        "publisher": podcast1.author
                                       ],
                           ["id": podcast2.id,
                            "title": podcast2.title,
                            "image": podcast2.imageURL.absoluteString,
                            "description": podcast2.description,
                            "publisher": podcast2.author
                           ]]]
        
        sut.load{result in
            switch result{
            case .failure(_):
                XCTFail("Expected success but got failure")
            case let .success(arrayPodcast):
                XCTAssertEqual(arrayPodcast, [podcast1, podcast2])
            
            }
            exp.fulfill()
            
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: podcastJson)
        client.completesWithData(jsonData)

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeAPodcast() -> Podcast{
        let randomID = Int.random(in: 100...1000)
        return Podcast(id: randomID, title: "A Hit Podcast Title", author: "Any Author", description: "A description for a podcast", imageURL: anyURL())
    }
    
    private func anyURL() -> URL{
        URL(string: "http://any-podcast-url.com")!
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
