//
//  FlickrClient.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/4/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import Foundation
import Alamofire

class FlickrClient: NSObject {


    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    // This function makes a request to Flickr for the search text and returns the number of pages for that search.  This number is then used to generate a random number so that every time the request is made it pulls a different set of images.
    
    func taskForGetRandomPage(search: String, completionHandlerForPhotos: @escaping (_ result: UInt32?, _ error: String?) -> Void) {
        
        let url = FlickrConstants.URL.ApiScheme + FlickrConstants.URL.ApiHost + FlickrConstants.URL.ApiPath
        
        var parameters = [FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.PhotoSearchMethod,  FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey, FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL, FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat, FlickrConstants.ParameterKeys.NoJSONCallBack: FlickrConstants.ParameterValues.DisableJSONCallBack, FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.PerPage, FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.SafeSearch]
        
        parameters[FlickrConstants.ParameterKeys.Text] = search
        
        //Alamo fire is used for the networking requests.
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: { response in
                
                switch response.result {
                    
                case .success:
                    
                    print("Success for Random")
                    // Select a random page number and return it to be used in get flickr photos function
                    // Check that JSON was returned
                    
                    guard  let JSON = response.result.value as? [String: AnyObject] else {
                        
                        print("Failed to get JSON")
                        
                        completionHandlerForPhotos(nil, "Failed to return JSON" )
                        
                        return
                        
                    }
                    
                    // Unwrap optionals to confirm that JSON is correct.
                    
                    if let photoDictionary = JSON["\(FlickrConstants.JSONResponseKeys.Photos)"] {
                        
                        if let photoPages = photoDictionary["\(FlickrConstants.JSONResponseKeys.Pages)"] as? UInt32 {
                            
                            let intPerPage = Int(FlickrConstants.ParameterValues.PerPage)
                            
                            let availablePages = min(4000/intPerPage!, Int(photoPages))
                            
                            let randomPage = arc4random_uniform(UInt32(availablePages)) + 1
                            
                            completionHandlerForPhotos(randomPage, nil)
                            
                        } else {
                            
                            completionHandlerForPhotos(nil, JSON[FlickrConstants.JSONResponseKeys.Message] as? String )
                            
                        }
                        
                    } else {
                        
                        completionHandlerForPhotos(nil, JSON[FlickrConstants.JSONResponseKeys.Message] as? String )
                        
                    }
                    
                case .failure:
                    
                    print("Failed to return \(String(describing: response.result.error?.localizedDescription))")
                    
                    completionHandlerForPhotos(nil, response.error?.localizedDescription )
                    
                }
            })
    }
    
    
    // This function takes the search text and random number from the previous function and returns a set of 20 images.
    
    func taskForGetPhotosFromSearch(search: String, randomPage: UInt32, completionForPosterPhotos: @escaping (_ result: [URL]?, _ error: String?) -> Void){
        
        let url = FlickrConstants.URL.ApiScheme + FlickrConstants.URL.ApiHost + FlickrConstants.URL.ApiPath
        
        var parameters = [FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.PhotoSearchMethod,  FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey, FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL, FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat, FlickrConstants.ParameterKeys.NoJSONCallBack: FlickrConstants.ParameterValues.DisableJSONCallBack, FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.PerPage, FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.SafeSearch]
        
        parameters[FlickrConstants.ParameterKeys.Text] = search
        parameters[FlickrConstants.ParameterKeys.Page] = String(randomPage)
        
        //Alamo fire was used for the networking requests.
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    
                    print("Success")
                    
                    // Check that JSON was returned
                    
                    guard  let JSON = response.result.value as? [String: AnyObject] else {
                        
                        print("Failed to get JSON")
                        
                        completionForPosterPhotos(nil, "Failed to return JSON" )
                        
                        return
                        
                    }
                    
                    // Unwrap optionals to confirm that JSON is correct.
                    
                    if let photoDictionary = JSON["\(FlickrConstants.JSONResponseKeys.Photos)"] {
                        
                        if let photoArray = photoDictionary["\(FlickrConstants.JSONResponseKeys.Photo)"] as? [[String:AnyObject]] {
                            
                            let urlArray = self.createPhotoArray(result: photoArray)
                            
                            completionForPosterPhotos(urlArray, nil)
                            
                        } else {
                            
                            print("Failed to Parse Photo Key.")
                            
                            completionForPosterPhotos(nil, JSON[FlickrConstants.JSONResponseKeys.Message] as? String )
                            
                        }
                        
                    } else {
                        
                        print("Failed to Parse Photos Key.")
                        
                        completionForPosterPhotos(nil, JSON[FlickrConstants.JSONResponseKeys.Message] as? String )
                        
                    }
                    
                case .failure:
                    
                    print("Failed to return \(String(describing: response.result.error?.localizedDescription))")
                    
                    completionForPosterPhotos(nil, response.error?.localizedDescription )
                    
                }
        }
    }
    
    
        // Take results from Flickr and return Array of URLs, checking to make sure there aren't any nil values
        
        func createPhotoArray(result: [[String:AnyObject]]) -> [URL] {
            
            var arrayOfPhotos = [] as [URL]
            
            for result in result {
                
                if (result[FlickrConstants.JSONResponseKeys.Image] as? String) != nil {
                    
                    if let imageURL = URL(string: result[FlickrConstants.JSONResponseKeys.Image] as! String) {
                        
                        arrayOfPhotos.append(imageURL)
                    }
                }
            }
            
            return arrayOfPhotos
        }
    


    // Create a singleton to access it easily
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}




