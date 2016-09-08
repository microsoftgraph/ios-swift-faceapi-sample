/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum FaceAPIResult<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}

class FaceAPI: NSObject {
    
    // Create person group
    static func createPersonGroup(personGroupId: String, name: String, userData: String?, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/"
        let urlWithParams = url + personGroupId
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": name]
        
        if let userData = userData {
            json["userData"] = userData
        }
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
        request.HTTPBody = jsonData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode

                if (statusCode == 200 || statusCode == 409) {
                    completion(result: .Success([]))
                }

                else {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! JSONDictionary
                        completion(result: .Failure(Error.ServiceError(json: json)))
                    }
                    catch {
                        completion(result: .Failure(Error.JSonSerializationError))
                    }
                }
            }
        }
        task.resume()
    }
    
    
    // Create person
    static func createPerson(personName: String, userData: String?, personGroupId: String, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        var json: [String: AnyObject] = ["name": personName]
        if let userData = userData {
            json["userData"] = userData
        }
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
        request.HTTPBody = jsonData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if statusCode == 200 {
                        completion(result: .Success(json))
                    }
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }

    
    // Upload face
    static func uploadFace(faceImage: UIImage, personId: String, personGroupId: String, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/persons/\(personId)/persistedFaces"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(faceImage)
        
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: pngRepresentation) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if statusCode == 200 {
                        completion(result: .Success(json))
                    }
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Post training
    static func trainPersonGroup(personGroupId: String, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/train"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    if statusCode == 202 {
                        completion(result: .Success([]))
                    }
                    else {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! JSONDictionary
                        completion(result: .Failure(Error.ServiceError(json: json)))
                    }
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }

    
    // Get training status
    static func getTrainingStatus(personGroupId: String, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/persongroups/\(personGroupId)/training"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "GET"
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    completion(result: .Success(json))
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Detect faces
    static func detectFaces(facesPhoto: UIImage, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(facesPhoto)
        
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: pngRepresentation) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if statusCode == 200 {
                        completion(result: .Success(json))
                    }
                    else {
                        completion(result: .Failure(Error.ServiceError(json: json as! [String : AnyObject])))
                    }
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    
    // Identify faces in people group
    static func identify(faces faceIds: [String], personGroupId: String, completion: (result: FaceAPIResult<JSON, Error>) -> Void) {

        let url = "https://api.projectoxford.ai/face/v1.0/identify"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ApplicationConstants.ocpApimSubscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        
        let json: [String: AnyObject] = ["personGroupId": personGroupId,
                                         "maxNumOfCandidatesReturned": 1,
                                         "confidenceThreshold": 0.7,
                                         "faceIds": faceIds
        ]
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
        request.HTTPBody = jsonData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            if let nsError = error {
                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode

                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if statusCode == 200 {
                        completion(result: .Success(json))
                    }
                    else {
                        completion(result: .Failure(Error.ServiceError(json: json as! JSONDictionary)))
                    }
                }
                catch {
                    completion(result: .Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
}
