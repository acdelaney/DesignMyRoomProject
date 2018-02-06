//
//  FlickrConstants.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/4/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

struct FlickrConstants {
    
    struct URL {
        static let ApiScheme = "https://"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        
    }
    
    struct ParameterKeys {

        static let Text = "text"
        static let Extras = "extras"
        static let APIKey = "api_key"
        static let Method = "method"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
        static let SafeSearch = "safe_search"
        
    }
    
    struct ParameterValues {

        static let MediumURL = "url_m"
        static let APIKey = "DUMMY_API_KEY"
        static let PhotoSearchMethod = "flickr.photos.search"
        static let ResponseFormat = "json"
        static let DisableJSONCallBack = "1" //1 means yes
        static let PerPage = "20"
        static let SafeSearch = "1"  //1 means safe
        
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Image = "url_m"
        static let Pages = "pages"
        static let Message = "message"
    }
    
}
