//
//  Podcast.swift
//  PodcastFeed
//
//  Created by Nav on 26/04/23.
//

import Foundation
import SwiftyJSON

public struct Results {
    public let podcast: Podcast
    
}

// MARK: - Result
public struct Podcast {
    public init(title: String, description: String, id: String, imageURL: URL, thumbnailURL: URL, publisher: String) {
        self.title = title
        self.description = description
        self.id = id
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.publisher = publisher
    }
    
    public var title: String
    public var description: String
    public var id: String
    public var imageURL: URL
    public var thumbnailURL: URL
    public var publisher: String
}


public struct Item {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let results = "results"
        static let podcast = "podcast"
        static let thumnail = "thumbnail"
        static let image = "image"
        static let title = "title_original"
        static let publisher = "publisher_original"
        static let id = "id"
        static let description = "description_highlighted"
        
        
    }
    var arrayPodcasts = [Podcast]()
    
    public init(json: JSON) {
        let arrayResults = json[SerializationKeys.results].array
        
        arrayResults?.enumerated().forEach{ index, element in
            let title = element[SerializationKeys.title].string
            let thumbnail = element[SerializationKeys.thumnail].url
            let imageURL = element[SerializationKeys.image].url
            let id = element[SerializationKeys.id].string
            let publisher = element[SerializationKeys.podcast][SerializationKeys.publisher].string
            let description = element[SerializationKeys.description].string
            let podcast = Podcast(title: title!, description: description! , id: id!, imageURL: imageURL!, thumbnailURL: thumbnail!, publisher: publisher!)
            arrayPodcasts.append(podcast)
        }
    }
}
