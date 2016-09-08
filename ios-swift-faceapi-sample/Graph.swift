/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum GraphResult<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}

struct Graph {
    
    var graphClient: MSGraphClient = {
        return MSGraphClient.defaultClient()
    }()
    
    // Read contacts
    func getUsers(with completion: (result: GraphResult<[MSGraphUser], Error>) -> Void) {
        graphClient.users().request().getWithCompletion {
            (userCollection: MSCollection?, next: MSGraphUsersCollectionRequest?, error: NSError?) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                if let users = userCollection {
                    completion(result: .Success(users.value as! [MSGraphUser]))
                }
            }
        }
    }
    
    
    
    // Get photovalue
    func getPhotoValue(forUser upn: String, with completion: (result: GraphResult<UIImage, Error>) -> Void) {
        graphClient.users(upn).photoValue().downloadWithCompletion {
            (url: NSURL?, response: NSURLResponse?, error: NSError?) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
                return
            }
            
            guard let picUrl = url else {
                completion(result: .Failure(Error.UnexpectedError(nsError: nil)))
                return
            }
            
            print(picUrl)
            
            let picData = NSData(contentsOfURL: picUrl)
            let picImage = UIImage(data: picData!)
            
            do {
               try NSFileManager.defaultManager().removeItemAtURL(picUrl)
            }
            catch (let error) {
                print("delete error", error)
            }
            
            if let validPic = picImage {
                completion(result: .Success(validPic))
            }
            else {
                completion(result: .Failure(Error.UnexpectedError(nsError: nil)))
            }
            
        }
    }
}
