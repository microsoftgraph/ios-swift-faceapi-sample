/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit
import MSAL
import MSGraphSDK

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
    let authenticationProvider: AuthenticationProvider? = {
        guard let authorityUrl = URL(string: ApplicationConstants.authority) else { return nil }
        
        var authenticationProvider: AuthenticationProvider?
        do {
            let authority = try MSALAADAuthority(url: authorityUrl)
            let clientId = ApplicationConstants.clientId
            authenticationProvider = try AuthenticationProvider(clientId: clientId, authority: authority)
        } catch let error as NSError {
            print("Error: ", error)
        }
        
        return authenticationProvider
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "selectPhoto" {
            let photoSelectorVC = segue.destination as! PhotoSelectorTableViewController
            photoSelectorVC.authenticationProvider = authenticationProvider
        }
    }
    
    // MARK:- IBAction
    
    @IBAction func connectToGraph(sender: AnyObject)
    {
        guard let authenticationProvider = self.authenticationProvider else { return }
        if state == .Connecting { return }
        
        setConnectButton(state: .Connecting)
        let scopes = ApplicationConstants.scopes
        
        authenticationProvider.acquireAuthToken(scopes: scopes) { (success, error) in
            if success {
                MSGraphClient.setAuthenticationProvider(self.authenticationProvider)
                self.setConnectButton(state: .ReadyToConnect)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "selectPhoto", sender: nil)
                }
                
                return
            }
            
            print("[Error] ", error!)
            self.setConnectButton(state: .Error)
        }
    }
    
    // MARK:- Private
    
    private func setConnectButton(state: State)
    {
        DispatchQueue.main.async {
            switch state {
            case .Connecting:
                self.connectButton.isEnabled = false
                self.connectButton.setTitle("Connecting", for: .normal)
            case .ReadyToConnect:
                self.connectButton.isEnabled = true
                self.connectButton.setTitle("Start by connecting to Microsoft Graph", for: .normal)
            case .Error:
                self.connectButton.isEnabled = true
                self.connectButton.setTitle("Connection failed. Retry.", for: .normal)
            }
        }
    }
}
