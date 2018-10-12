/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum GraphResult<T, GraphError: Error> {
  case success(T)
  case failure(GraphError)
}

struct Graph {
  
  var graphClient: MSGraphClient = {
    return MSGraphClient.defaultClient()
  }()
  
  // Read contacts
  func getUsers(with completion: @escaping (_ result: GraphResult<[MSGraphUser], NetworkError>) -> Void) {
    
    graphClient.users()?.request()?.getWithCompletion({ (userCollection, next, error) in
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        if let users = userCollection {
          completion(.success(users.value as! [MSGraphUser]))
        }
      }
    })
  }
  
  
  
  // Get photovalue
  func getPhotoValue(forUser upn: String,
                     with completion: @escaping (_ result: GraphResult<UIImage, NetworkError>) -> Void) {
    
    graphClient.users(upn)?.photoValue()?.download(completion: { (url, response, error) in
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
        return
      }
      
      guard let picUrl = url else {
        completion(.failure(NetworkError.unexpectedError(nsError: nil)))
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
        completion(.failure(NetworkError.unexpectedError(nsError: nil)))
      }
    })
    
    
  }
}
