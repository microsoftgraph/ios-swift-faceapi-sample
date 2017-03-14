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
    
    override func viewDidAppear(_ animated: Bool) {
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
            case .success(let result):
                let userCollection = result
                for user in userCollection {
                    let person = Person(name: user.displayName, upn: user.userPrincipalName, image: nil)
                    self.persons.append(person)
                }
                
                DispatchQueue.main.async( execute: {
                    self.tableView.reloadData()
                })
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}


// MARK: - UITableView
extension SelectPersonTableViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        cell.textLabel!.text = persons[indexPath.row].name
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var person = persons[indexPath.row]
        graph.getPhotoValue(forUser: person.upn) { (result) in
            switch (result) {
            case .success(let result):
                let image = result
                person.image = image
                self.delegate.select(person)
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                break
                
            case .failure(let error):
                print("Error", error)
                self.alert("Error", message: "Check log for more details")
                break
            }
        }
    }
}
