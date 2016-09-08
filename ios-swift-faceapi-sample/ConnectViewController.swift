/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum State {
    case Connecting
    case ReadyToConnect
    case Error
}

class ConnectViewController: UIViewController {

    @IBOutlet var connectButton: UIButton!
    var state: State = .ReadyToConnect
    
    let authentication: Authentication = Authentication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectPhoto" {
            let photoSelectorVC = segue.destinationViewController as! PhotoSelectorTableViewController
            photoSelectorVC.authentication = authentication
        }
    }
}


// Connect action & UI Helpers
extension ConnectViewController {
    
    @IBAction func connectToGraph(sender: AnyObject) {
        
        if state == .Connecting {
            return
        }
        
        setConnectButton(.Connecting)
        
        let clientId = ApplicationConstants.clientId
        let scopes = ApplicationConstants.scopes
        
        authentication.connectToGraph(withClientId: clientId, scopes: scopes) { (result) in
            switch result {
            case .Success(_):
                MSGraphClient.setAuthenticationProvider(self.authentication.authenticationProvider)
                self.setConnectButton(.ReadyToConnect)
                self.performSegueWithIdentifier("selectPhoto", sender: nil)
                break
            case .Failure(let error):
                print("[Error]", error)
                self.setConnectButton(.Error)
                break
            }
        }
    }
    
    func setConnectButton(state: State) {
        switch state {
        case .Connecting:
            connectButton.enabled = false
            connectButton.setTitle("Connecting", forState: .Normal)
            break
        case .ReadyToConnect:
            connectButton.enabled = true
            connectButton.setTitle("Start by connecting to Microsoft Graph", forState: .Normal)
            break
        case .Error:
            connectButton.enabled = true
            connectButton.setTitle("Connection failed. Retry.", forState: .Normal)
            break
        }
    }
}