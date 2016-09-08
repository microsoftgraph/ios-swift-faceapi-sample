/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

private enum CellIdentifier {
    static let selectPersonCell = "selectPersonCell"
    static let selectPhotoCell = "selectPhotoCell"
    static let photoCell = "photoCell"
}

private enum SelectedType {
    case singlePerson
    case photoForIdentification
}

struct Person {
    var name: String
    var upn: String
    var image: UIImage?
}

protocol PersonSelecting {
    func select(person: Person)
}


class PhotoSelectorTableViewController: UITableViewController {
    
    var authentication: Authentication!
    
    var selectedPerson: Person?
    var selectedPhoto: UIImage?
    
    let imagePicker = UIImagePickerController()
    
    private var selectedType: SelectedType!
    
    @IBOutlet var startButton: UIBarButtonItem!
    @IBOutlet var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setHidesBackButton(true, animated: false)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        imagePicker.delegate = self
        startButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectPerson" {
            let selectPersonVC = segue.destinationViewController as! SelectPersonTableViewController
            selectPersonVC.delegate = self
        }
            
        else if segue.identifier == "startFaceAPI" {
            let faceAPIVC = segue.destinationViewController as! FaceApiTableViewController
            faceAPIVC.selectedPhoto = selectedPhoto
            faceAPIVC.selectedPerson = selectedPerson
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = selectedPerson,
            _ = selectedPhoto {
            startButton.enabled = true
        }
        else {
            startButton.enabled = false
        }
    }

}

// MARK: - PersonSelecting, Photo selecting
extension PhotoSelectorTableViewController: PersonSelecting, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func select(person: Person) {
        selectedPerson = person
        tableView.reloadData()
    }
    
    func selectPhoto() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if selectedType == .singlePerson {
                let person = Person(name: "Local photo", upn: "local photo", image: pickedImage)
                selectedPerson = person
            }
            else {
                selectedPhoto = pickedImage
            }
        }

        dismissViewControllerAnimated(true, completion: nil)
        
        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - UITableView
extension PhotoSelectorTableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = selectedPhoto {
            return 3
        }
        else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.selectPersonCell, forIndexPath: indexPath)
            if let person = selectedPerson {
                cell.textLabel!.text = person.name
                cell.imageView!.image = person.image
            }
        }
        else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.selectPhotoCell, forIndexPath: indexPath)
            if let _ = selectedPhoto {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.photoCell, forIndexPath: indexPath)
            if let photo = selectedPhoto {
                let imageView = cell.viewWithTag(101) as! UIImageView
                imageView.image = photo
            }
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
            let alertController = UIAlertController(title: "Select source", message: "", preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: "Graph Directory", style: .Default, handler: { (action) in
                self.performSegueWithIdentifier("selectPerson", sender: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Photos", style: .Default, handler: { (action) in
                self.selectedType = .singlePerson
                self.selectPhoto()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
            
            
        }
        else if indexPath.row == 1 {
            self.selectedType = .photoForIdentification
            selectPhoto()
        }
    }
}


extension PhotoSelectorTableViewController {
    
    @IBAction func start(sender: AnyObject) {
        performSegueWithIdentifier("startFaceAPI", sender: nil)
    }
    
    @IBAction func disconnect(sender: AnyObject) {
        authentication.disconnect()
        navigationController?.popViewControllerAnimated(true)
    }
}

