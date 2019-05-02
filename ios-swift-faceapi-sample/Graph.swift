/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum GraphResult<T, E>
{
    case Success(T)
    case Failure(E)
}

struct Graph
{
    var graphClient: MSGraphClient = {
        return MSGraphClient.defaultClient()
    }()
    
    // Read contacts
    func getUsers(with completion: @escaping (_ result: GraphResult<[MSGraphUser], Error>) -> Void)
    {
        graphClient.users().request().getWithCompletion { (userCollection, next, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                if let users = userCollection {
                    completion(.Success(users.value as! [MSGraphUser]))
                }
            }
        }
    }
    
    // Get photovalue
    func getPhotoValue(forUser upn: String, with completion: @escaping (_ result: GraphResult<UIImage, Error>) -> Void)
    {
        graphClient.users(upn).photoValue().download { (url, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
                return
            }
            
            guard let picUrl = url else {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nil)))
                return
            }
            
            print(picUrl)
            
            let picData = NSData(contentsOf: picUrl)
            let picImage = UIImage(data: picData! as Data)
            
            do {
                try FileManager.default.removeItem(at: picUrl)
            } catch (let error) {
                print("delete error", error)
            }
            
            if let validPic = picImage {
                completion(.Success(validPic))
            } else {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nil)))
            }
            
        }
    }
}
