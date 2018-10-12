/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum FaceAPIResult<T, NetworkError: Error> {
  case success(T)
  case failure(NetworkError)
}

class FaceAPI: NSObject {
  
  // Create person group
  static func createPersonGroup(
    personGroupId: String,
    name: String,
    userData: String?,
    completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/persongroups/"
    let urlWithParams = url + personGroupId
    
    let request = NSMutableURLRequest(url: URL(string: urlWithParams)!)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    var json: [String: AnyObject] = ["name": name as AnyObject]
    
    if let userData = userData {
      json["userData"] = userData as AnyObject
    }
    
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      } else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        if (statusCode == 200 || statusCode == 409) {
          completion(.success([] as AnyObject))
        } else {
          do {
            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! JSONDictionary
            completion(.failure(NetworkError.serviceError(json: json)))
          }
          catch {
            completion(.failure(NetworkError.jsonSerializationError))
          }
        }
      }
    }
    task.resume()
  }
  
  
  // Create person
  static func createPerson(personName: String,
                           userData: String?,
                           personGroupId: String,
                           completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    var json: [String: AnyObject] = ["name": personName as AnyObject]
    if let userData = userData {
      json["userData"] = userData as AnyObject
    }
    
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
          if statusCode == 200 {
            completion(.success(json as AnyObject))
          }
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
  
  
  // Upload face
  static func uploadFace(faceImage: UIImage,
                         personId: String,
                         personGroupId: String,
                         completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons/\(personId)/persistedFaces"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    let pngRepresentation = faceImage.pngData()
    
    let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
          if statusCode == 200 {
            completion(.success(json as AnyObject))
          }
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
  
  
  // Post training
  static func trainPersonGroup(personGroupId: String,
                               completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/train"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        do {
          if statusCode == 202 {
            completion(.success([] as AnyObject))
          }
          else {
            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! JSONDictionary
            completion(.failure(NetworkError.serviceError(json: json)))
          }
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
  
  
  // Get training status
  static func getTrainingStatus(personGroupId: String,
                                completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/training"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "GET"
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
          completion(.success(json as AnyObject))
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
  
  
  // Detect faces
  static func detectFaces(facesPhoto: UIImage, completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    let pngRepresentation = facesPhoto.pngData()
    
    let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
          if statusCode == 200 {
            completion(.success(json as AnyObject))
          }
          else {
            completion(.failure(NetworkError.serviceError(json: json as! [String : AnyObject])))
          }
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
  
  
  // Identify faces in people group
  static func identify(faces faceIds: [String], personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, NetworkError>) -> Void) {
    
    let url = "https://api.projectoxford.ai/face/v1.0/identify"
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    
    let json: [String: AnyObject] = ["personGroupId": personGroupId as AnyObject,
                                     "maxNumOfCandidatesReturned": 1 as AnyObject,
                                     "confidenceThreshold": 0.7 as AnyObject,
                                     "faceIds": faceIds as AnyObject
    ]
    
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    request.httpBody = jsonData
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      if let nsError = error {
        completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
      }
      else {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
          if statusCode == 200 {
            completion(.success(json as AnyObject))
          } else {
            completion(.failure(NetworkError.serviceError(json: json as! JSONDictionary)))
          }
        }
        catch {
          completion(.failure(NetworkError.jsonSerializationError))
        }
      }
    }
    task.resume()
  }
}
