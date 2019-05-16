/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

private enum CellIdentifier
{
    static let loadingCell = "loadingCell"
    static let photoCell = "photoCell"
    static let resultCell = "resultCell"
    static let notFoundCell = "notFoundCell"
}

struct Result
{
    let image: UIImage
    let otherInformation: String
}

struct Face
{
    let faceId: String
    let height: Int
    let width: Int
    let top: Int
    let left: Int
}

private enum FaceAPIConstant
{
    static let personGroupId = "sample-person-group-using-graph"
}

class FaceApiTableViewController: UITableViewController
{
    var selectedPerson: Person!
    var selectedPhoto: UIImage!
    var isLoading: Bool = true
    var result = [Result]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        identifyFace()
    }
}


// MARK: - TableView
extension FaceApiTableViewController
{
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isLoading {
            return 2
        } else {
            return 1 + max(result.count, 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.photoCell, for: indexPath)
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = selectedPhoto
            return cell
        } else if indexPath.row == 1 && isLoading == true {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifier.loadingCell, for: indexPath)
        } else {
            if result.count - 1 < indexPath.row - 1 {
                return tableView.dequeueReusableCell(withIdentifier: CellIdentifier.notFoundCell, for: indexPath)
            }
            
            let record = result[indexPath.row - 1]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.resultCell, for: indexPath)
            let imageView = cell.viewWithTag(101) as! UIImageView
            let label = cell.viewWithTag(102) as! UILabel
            
            imageView.image = record.image
            label.text = record.otherInformation
            
            return cell
        }
    }
}


// MARK: - Face API
extension FaceApiTableViewController
{

    // In order for detection to work, 
    // We need to: 
    //  1. create personGroup   :
    //  2. add a person to personGroup
    //  3. upload person's face(s)
    //  4. train
    //  5. check train completion
    //  5. detect faces in a photo
    //  6. identify
   
    func identifyFace()
    {
        createPersonGroup(groupId: FaceAPIConstant.personGroupId)
    }
    
    func createPersonGroup(groupId: String) {
        FaceAPI.createPersonGroup(personGroupId: groupId,
                                  name: "SampleGroup",
                                  userData: "This is a sample group") { (result) in
                                    switch result {
                                    case .Success(let json):
                                        print("Created person group - ", json)
                                        self.addPerson(name: self.selectedPerson.name, userData: nil, personGroupId: groupId)
                                    case .Failure(let error):
                                        print("Error creating person group - ", error)
                                        self.alert(title: "Error", message: "Check log for more details")
                                    }
        }
    }
    
    func addPerson(name: String, userData: String?, personGroupId: String)
    {
        FaceAPI.createPerson(personName: name, userData: userData, personGroupId: personGroupId) { (result) in
            switch result {
            case .Success(let json):
                
                let personId = json["personId"] as! String
                print("Created person - ", personId)
                self.uploadPersonFace(image: self.selectedPerson.image!, personId: personId, personGroupId: personGroupId)
                break
            case .Failure(let error):
                print("Error adding a person - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
            }
        }
    }

    
    func uploadPersonFace(image: UIImage, personId: String, personGroupId: String)
    {
        FaceAPI.uploadFace(faceImage: image, personId: personId, personGroupId: personGroupId) { (result) in
            switch result {
            case .Success(_):
                print("face uploaded - ", personId)
                self.train(personGroupId: personGroupId, personToFind: personId)
                break
            case .Failure(let error):
                print("Error uploading a face - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            }    
        }
    }

    func train(personGroupId: String, personToFind: String)
    {
        FaceAPI.trainPersonGroup(personGroupId: personGroupId) { (result) in
            switch result {
            case .Success(_):
                print("train posted")
                self.checkForTrainComplete(personGroupId: personGroupId, completion: { 
                    self.detectFaces(photo: self.selectedPhoto, completion: { (faces) in
                        self.identifyFaces(faces: faces, personGroupId: personGroupId, personToFind: personToFind)
                    })
                })
                break
            case .Failure(let error):
                print("Error posting to train - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            }
        }
    }
    

    func checkForTrainComplete(personGroupId: String, completion: @escaping () -> Void) {
        FaceAPI.getTrainingStatus(personGroupId: personGroupId) { (result) in
            switch result {
            case .Success(let json):
                print("training complete - ", json)
                let status = json["status"] as! String
                
                if status == "notstarted" || status == "running" {
                    print("Training in progress")
                    
                    let delayTime = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.checkForTrainComplete(personGroupId: personGroupId, completion: completion)
                    }
                }
                else if status == "failed" {
                    print("Training failed -", json)
                    self.alert(title: "Error", message: "Check log for more details")
                }
                else if status == "succeeded" {
                    print("Training succeeded")
                    completion()
                }
                
                break
            case .Failure(let error):
                print("Training incomplete or error - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            }
        }
    }

    func detectFaces(photo: UIImage, completion: @escaping (_ faces: [Face]) -> Void)
    {
        FaceAPI.detectFaces(facesPhoto: photo) { (result) in
            switch result {
            case .Success(let json):
                var faces = [Face]()
                
                let detectedFaces = json as! JSONArray
                for item in detectedFaces {
                    let face = item as! JSONDictionary
                    let faceId = face["faceId"] as! String
                    let rectangle = face["faceRectangle"] as! [String: AnyObject]
                    
                    let detectedFace = Face(faceId: faceId,
                                            height: rectangle["top"] as! Int,
                                            width: rectangle["width"] as! Int,
                                            top: rectangle["top"] as! Int,
                                            left: rectangle["left"] as! Int)
                    faces.append(detectedFace)
                }
                completion(faces)
                break
            case .Failure(let error):
                print("DetectFaces error - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
            }
        }
    }
    
    func identifyFaces(faces: [Face], personGroupId: String, personToFind: String) {
        
        print("Looking for", personToFind)
        print("in group", personGroupId)
        var faceIds = [String]()
        for face in faces {
            faceIds.append(face.faceId)
        }
        
        FaceAPI.identify(faces: faceIds, personGroupId: personGroupId) { (result) in
            switch result {
            case .Success(let json):
                let jsonArray = json as! JSONArray

                for item in jsonArray {
                    let face = item as! JSONDictionary
                    
                    let faceId = face["faceId"] as! String
                    let candidates = face["candidates"] as! JSONArray

                    for candidate in candidates {
                        
                        if candidate["personId"] as! String == personToFind {
                            // find face information based on faceId
                            for face in faces {
                                if face.faceId == faceId {
                                    let faceImage = self.cropFace(face: face, image: self.selectedPhoto)
                                    let confidence = candidate["confidence"] as! CFNumber
                                    
                                    var outputString = "confidence: \(confidence)\n"
                                    outputString += "dimensions: \n";
                                    outputString += "   top   : \(Int(face.top))\n"
                                    outputString += "   left  : \(Int(face.left))\n"
                                    outputString += "   width : \(Int(face.width))\n"
                                    outputString += "   height: \(Int(face.height))\n"
                                    
                                    let detectedFace = Result(image: faceImage, otherInformation: outputString)
                                    self.result.append(detectedFace)
                                }
                            }
                        }
                    }
                    
                    self.isLoading = false
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .Failure(let error):
                print("Identifying faces error - ", error)
                self.alert(title: "Error", message: "Check log for more details")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            }
        }
    }

    
    func cropFace(face: Face, image: UIImage) -> UIImage
    {
        let croppedSection = CGRect(x: CGFloat(face.left), y: CGFloat(face.top), width: CGFloat(face.width), height: CGFloat(face.height))
        let imageRef = image.cgImage!.cropping(to: croppedSection)
        
        let croppedImage = UIImage(cgImage: imageRef!)
        
        return croppedImage
    }
    
}
