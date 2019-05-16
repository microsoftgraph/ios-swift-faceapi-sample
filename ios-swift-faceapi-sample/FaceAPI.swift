/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum FaceAPIResult<T, E>
{
    case Success(T)
    case Failure(E)
}

class FaceAPI: NSObject
{
    // Create person group
    static func createPersonGroup(personGroupId: String, name: String, userData: String?, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/persongroups/"
        let urlWithParams = url + personGroupId
        
        var request = URLRequest(url: URL(string: urlWithParams)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": name as AnyObject]
        
        if let userData = userData {
            json["userData"] = userData as AnyObject
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200 || statusCode == 409) {
                    completion(.Success([] as AnyObject))
                } else {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! JSONDictionary
                        completion(.Failure(ErrorType.ServiceError(json: json)))
                    } catch {
                        completion(.Failure(ErrorType.JSonSerializationError))
                    }
                }
            }
        }
        task.resume()
    }
    
    
    // Create person
    static func createPerson(personName: String, userData: String?, personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/persongroups/\(personGroupId)/persons"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": personName as AnyObject]
        if let userData = userData {
            json["userData"] = userData as AnyObject
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.Success(json as AnyObject))
                    }
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }

    
    // Upload face
    static func uploadFace(faceImage: UIImage, personId: String, personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/persongroups/\(personGroupId)/persons/\(personId)/persistedFaces"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = faceImage.pngData()
        
        let task = URLSession.shared.uploadTask(with: request, from: pngRepresentation) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.Success(json as AnyObject))
                    }
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Post training
    static func trainPersonGroup(personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/persongroups/\(personGroupId)/train"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    if statusCode == 202 {
                        completion(.Success([] as AnyObject))
                    } else {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! JSONDictionary
                        completion(.Failure(ErrorType.ServiceError(json: json)))
                    }
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }

    
    // Get training status
    static func getTrainingStatus(personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/persongroups/\(personGroupId)/training"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    completion(.Success(json as AnyObject))
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Detect faces
    static func detectFaces(facesPhoto: UIImage, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/detect?returnFaceId=true&returnFaceLandmarks=false"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = facesPhoto.pngData()
        
        let task = URLSession.shared.uploadTask(with: request, from: pngRepresentation) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.Success(json as AnyObject))
                    } else {
                        completion(.Failure(ErrorType.ServiceError(json: json as! [String : AnyObject])))
                    }
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Identify faces in people group
    static func identify(faces faceIds: [String], personGroupId: String, completion: @escaping (_ result: FaceAPIResult<JSON, Error>) -> Void)
    {
        let url = "\(ApplicationConstants.faceApiEndpoint)/identify"
        var request = URLRequest(url: URL(string: url)!)
        
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let nsError = error as NSError? {
                completion(.Failure(ErrorType.UnexpectedError(nsError: nsError)))
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode

                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.Success(json as AnyObject))
                    } else {
                        completion(.Failure(ErrorType.ServiceError(json: json as! JSONDictionary)))
                    }
                } catch {
                    completion(.Failure(ErrorType.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
}
