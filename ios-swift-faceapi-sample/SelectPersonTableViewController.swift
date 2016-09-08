/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

class SelectPersonTableViewController: UITableViewController {

    var persons: [Person] = [Person]()
    var graph = Graph()
    
    var delegate: PersonSelecting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadDirectory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Graph
extension SelectPersonTableViewController {
    func loadDirectory() {
        persons.removeAll()
        
        graph.getUsers { (result) in
            switch (result) {
            case .Success(let result):
                let userCollection = result
                for user in userCollection {
                    let person = Person(name: user.displayName, upn: user.userPrincipalName, image: nil)
                    self.persons.append(person)
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
                break
            case .Failure(let error):
                print(error)
                break
            }
        }
    }
}


// MARK: - UITableView
extension SelectPersonTableViewController {
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
        cell.textLabel!.text = persons[indexPath.row].name
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var person = persons[indexPath.row]
        graph.getPhotoValue(forUser: person.upn) { (result) in
            switch (result) {
            case .Success(let result):
                let image = result
                person.image = image
                self.delegate.select(person)
                dispatch_async(dispatch_get_main_queue(),{
                    self.navigationController?.popViewControllerAnimated(true)
                })
                break
                
            case .Failure(let error):
                print("Error", error)
                self.alert("Error", message: "Check log for more details")
                break
            }
        }
    }
}
