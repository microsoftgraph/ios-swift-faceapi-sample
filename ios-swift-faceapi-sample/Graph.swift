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
        
       // graphClient.users().request().expand("?$orderBy=userPhoto%20asc") .getWithCompletion {
        
        var options = [MSRequestOptions]()
        var option = MSRequestOptions()
        option.appendOption(toQueryString: "?$filter=userPhoto ne null")
        options.append(option)
        graphClient.users().request(withOptions: options).getWithCompletion{
        //graphClient.users().request().getWithCompletion{

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
