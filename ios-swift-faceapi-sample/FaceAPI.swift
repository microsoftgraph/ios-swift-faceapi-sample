/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum FaceAPIResult<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
}

class FaceAPI: NSObject {
    
    // Create person group
    static func createPersonGroup(_ personGroupId: String, name: String, userData: String?, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/"
        let urlWithParams = url + personGroupId
        
        let request = NSMutableURLRequest(url: URL(string: urlWithParams)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": name as AnyObject]
        
        if let userData = userData {
            json["userData"] = userData as AnyObject?
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode

                if (statusCode == 200 || statusCode == 409) {
                    completion(.success([] as AnyObject) )
                }

                else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! JSONDictionary
                        completion(.failure(Error.ServiceError(json: json)))
                    }
                    catch {
                        completion(.failure(Error.JSonSerializationError))
                    }
                }
            }
        }) 
        task.resume()
    }
    
    
    // Create person
    static func createPerson(_ personName: String, userData: String?, personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": personName as AnyObject]
        if let userData = userData {
            json["userData"] = userData as AnyObject?
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.success(json as AnyObject) )
                    }
                }
                catch {
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }

    
    // Upload face
    static func uploadFace(_ faceImage: UIImage, personId: String, personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons/\(personId)/persistedFaces"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(faceImage)
        
        let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
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
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }
    
    
    // Post training
    static func trainPersonGroup(_ personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/train"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
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
                        completion(.failure(Error.ServiceError(json: json)))
                    }
                }
                catch {
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }

    
    // Get training status
    static func getTrainingStatus(_ personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/training"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
            }
            else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    completion(.success(json as AnyObject))
                }
                catch {
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }
    
    
    // Detect faces
    static func detectFaces(_ facesPhoto: UIImage, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(facesPhoto)
        
        let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
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
                        completion(.failure(Error.ServiceError(json: json as! [String : AnyObject])))
                    }
                }
                catch {
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }
    
    
    // Identify faces in people group
    static func identify(faces faceIds: [String], personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void) {

        let url = "https://api.projectoxford.ai/face/v1.0/identify"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        
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
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let nsError = error {
                completion(.failure(Error.UnexpectedError(nsError: nsError as NSError?)))
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
                        completion(.failure(Error.ServiceError(json: json as! JSONDictionary)))
                    }
                }
                catch {
                    completion(.failure(Error.JSonSerializationError))
                }
            }
        }) 
        task.resume()
    }
}
