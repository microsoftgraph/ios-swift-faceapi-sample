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
    
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableView.automaticDimension
    
    imagePicker.delegate = self
    startButton.isEnabled = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "selectPerson" {
      let selectPersonVC = segue.destination as! SelectPersonTableViewController
      selectPersonVC.delegate = self
    }
      
    else if segue.identifier == "startFaceAPI" {
      let faceAPIVC = segue.destination as! FaceApiTableViewController
      faceAPIVC.selectedPhoto = selectedPhoto
      faceAPIVC.selectedPerson = selectedPerson
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let _ = selectedPerson,
      let _ = selectedPhoto {
      startButton.isEnabled = true
    }
    else {
      startButton.isEnabled = false
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
    imagePicker.sourceType = .photoLibrary
    
    present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      if selectedType == .singlePerson {
        let person = Person(name: "Local photo", upn: "local photo", image: pickedImage)
        selectedPerson = person
      }
      else {
        selectedPhoto = pickedImage
      }
    }
    
    dismiss(animated: true, completion: nil)
    
    tableView.reloadData()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}


// MARK: - UITableView
extension PhotoSelectorTableViewController {
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _ = selectedPhoto {
      return 3
    }
    else {
      return 2
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell
    
    if indexPath.row == 0 {
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.selectPersonCell, for: indexPath)
      if let person = selectedPerson {
        cell.textLabel!.text = person.name
        cell.imageView!.image = person.image
      }
    }
    else if indexPath.row == 1 {
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.selectPhotoCell, for: indexPath)
      if let _ = selectedPhoto {
        cell.accessoryType = .checkmark
      }
      else {
        cell.accessoryType = .none
      }
    }
    else {
      cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.photoCell, for: indexPath)
      if let photo = selectedPhoto {
        let imageView = cell.viewWithTag(101) as! UIImageView
        imageView.image = photo
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      
      let alertController = UIAlertController(title: "Select source", message: "", preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "Graph Directory", style: .default, handler: { (action) in
        self.performSegue(withIdentifier: "selectPerson", sender: nil)
      }))
      alertController.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (action) in
        self.selectedType = .singlePerson
        self.selectPhoto()
      }))
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
      present(alertController, animated: true, completion: nil)
      
      
    }
    else if indexPath.row == 1 {
      self.selectedType = .photoForIdentification
      selectPhoto()
    }
  }
}


extension PhotoSelectorTableViewController {
  
  @IBAction func start(sender: AnyObject) {
    performSegue(withIdentifier: "startFaceAPI", sender: nil)
  }
  
  @IBAction func disconnect(sender: AnyObject) {
    authentication.disconnect()
    navigationController?.popViewController(animated: true)
  }
}

