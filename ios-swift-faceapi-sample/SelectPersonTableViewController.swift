/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

class SelectPersonTableViewController: UITableViewController
{
    var persons: [Person] = [Person]()
    var graph = Graph()
    var delegate: PersonSelecting!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        loadDirectory()
    }
    
    // MARK: - Graph
    
    func loadDirectory()
    {
        persons.removeAll()
        
        graph.getUsers { (result) in
            switch (result) {
            case .Success(let result):
                let userCollection = result
                for user in userCollection {
                    let person = Person(name: user.displayName, upn: user.userPrincipalName, image: nil)
                    self.persons.append(person)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return persons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        cell.textLabel!.text = persons[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var person = persons[indexPath.row]
        graph.getPhotoValue(forUser: person.upn) { (result) in
            switch (result) {
            case .Success(let result):
                let image = result
                person.image = image
                self.delegate.select(person: person)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .Failure(let error):
                print("Error", error)
                self.alert(title: "Error", message: "Check log for more details")
            }
        }
    }
}
