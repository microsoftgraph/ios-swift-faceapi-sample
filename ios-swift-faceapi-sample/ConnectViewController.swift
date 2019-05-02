/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

enum State
{
    case Connecting
    case ReadyToConnect
    case Error
}

class ConnectViewController: UIViewController
{
    @IBOutlet var connectButton: UIButton!
    var state: State = .ReadyToConnect
    let authentication: Authentication = Authentication()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "selectPhoto" {
            let photoSelectorVC = segue.destination as! PhotoSelectorTableViewController
            photoSelectorVC.authentication = authentication
        }
    }
    
    // MARK:- IBAction
    
    @IBAction func connectToGraph(sender: AnyObject)
    {
        if state == .Connecting { return }
        
        setConnectButton(state: .Connecting)

        let clientId = ApplicationConstants.clientId
        let scopes = ApplicationConstants.scopes

        authentication.acquireAuthToken(clientId: clientId, scopes: scopes) { (success, error) in
            
            if success {
                MSGraphClient.setAuthenticationProvider(self.authentication.authenticationProvider)
                self.setConnectButton(state: .ReadyToConnect)
                self.performSegue(withIdentifier: "selectPhoto", sender: nil)
                
                return
            }
            
            print("[Error] ", error)
            self.setConnectButton(state: .Error)
        }
    }
    
    // MARK:- Private
    
    private func setConnectButton(state: State)
    {
        switch state {
        case .Connecting:
            connectButton.isEnabled = false
            connectButton.setTitle("Connecting", for: .normal)
        case .ReadyToConnect:
            connectButton.isEnabled = true
            connectButton.setTitle("Start by connecting to Microsoft Graph", for: .normal)
        case .Error:
            connectButton.isEnabled = true
            connectButton.setTitle("Connection failed. Retry.", for: .normal)
        }
    }
}
