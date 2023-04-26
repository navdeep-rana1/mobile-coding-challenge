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
import SwiftyJSON

final class PodcastFeedTests: XCTestCase {

   func test_init_doesnotRequestPodcastsFromBackendOnCreation()
    {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.getPodcastCallCount, 0)
        
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
       
        let exp = expectation(description: "wait for request")
        let jsonData = jsonDataResponse()
        sut.load{result in
            switch result{
            case .failure(_):
                XCTFail("Expected success but got failure")
            case let .success(arrayPodcast):
                XCTAssertEqual(arrayPodcast[0].publisher, "Matt Feury")
            case .failure(_):
                XCTFail("Expected success but got failure")
                
            }
            exp.fulfill()
            
        }
        client.completesWithData(jsonData!)

        wait(for: [exp], timeout: 1.0)
    }
    
//    // MARK: - Helpers
//    
    private func jsonDataResponse() -> Data?{
        let mainBundle = Bundle(identifier: "com.heyhub.PodcastFeedTests")
        let bundle = Bundle(for: PodcastFeedTests.self)
        let path = bundle.path(forResource: "Dummy", ofType: "json")
        return try! Data(contentsOf: URL(fileURLWithPath: path!))
    }
    
    private func anyURL() -> URL{
        URL(string: "http://any-podcast-url.com")!
    }
    private func makeSUT() -> (PodcastLoaderAPI, PodcastClientSpy){
        let client = PodcastClientSpy()
        let sut = PodcastLoaderAPI(client: client)
        return (sut, client)
    }

    private func anyError() -> NSError{
        NSError(domain: "Any podcast error", code: 10)
    }
    
    class PodcastClientSpy: PodcastClient{
        
        typealias Result = PodcastClientResult
        var getPodcastCallCount = 0
        var arrayCompletions = [(Result) -> Void]()

        
        func getPodcasts(completion: @escaping (Result) -> Void)
        {
            getPodcastCallCount += 1
            arrayCompletions.append(completion)
        }
        
        func completes(with error: PodcastApiError, at index: Int = 0){
            arrayCompletions[index](.failure(error))
        }
        
        func completesWithData(_ data: Data, at index: Int = 0){
            let json = try! JSON(data: data)
            arrayCompletions[index](.success(json))
        }
    }
}
