/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum GraphResult<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
}

struct Graph {
    
    var graphClient: MSGraphClient = {
        return MSGraphClient.defaultClient()
    }()
    
    // Read contacts
    func getUsers(with completion: @escaping (_ result: GraphResult<[MSGraphUser], NSError>) -> Void) {
        
        //Note: This query does not cause a server-side filtering of users. If the query is run against
        // organizations with large numbers of users, up to 999 users are returned in the response. Users
        // can include conference rooms which do not have pictures.  
        //If you need server-side filtering, use the Microsoft Graph REST API.
        graphClient.users().request().select(ApplicationConstants.selectString).order(by: ApplicationConstants.orderByString).getWithCompletion {

            (userCollection: MSCollection?, next: MSGraphUsersCollectionRequest?, error: Swift.Error?) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError? )as NSError))
            }
            else {
                if let users = userCollection {
                    completion(.success(users.value as! [MSGraphUser]))
                }
            }
        }
    }
    
    
    
    // Get photovalue
    func getPhotoValue(forUser upn: String, with completion: @escaping (_ result: GraphResult<UIImage, NSError>) -> Void) {
        graphClient.users(upn).photoValue().download {
            (url: URL?, response: URLResponse?, error: Swift.Error?) in
            
            if let nsError = error {
                completion(.failure( Error.UnexpectedError(nsError: nsError as NSError?) as NSError))
                return
            }
            
            guard let picUrl = url else {
                completion(.failure(Error.UnexpectedError(nsError: nil) as NSError))
                return
            }
            
            print(picUrl)
            
            let picData = NSData(contentsOf: picUrl)
            let picImage = UIImage(data: picData! as Data)
            
            do {
               try FileManager.default.removeItem(at: picUrl)
            }
            catch (let error) {
                print("delete error", error)
            }
            
            if let validPic = picImage {
                completion(.success(validPic))
            }
            else {
                completion(.failure(Error.UnexpectedError(nsError: nil) as NSError))
            }
            
        }
    }
}
