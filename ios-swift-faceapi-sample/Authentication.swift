/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation

struct Authentication
{
    var authenticationProvider: NXOAuth2AuthenticationProvider?
        {
        get {
            return NXOAuth2AuthenticationProvider.sharedAuth()
        }
    }
}

extension Authentication
{
    func acquireAuthToken(clientId: String, scopes: [String], completion:@escaping (_ success:Bool, _ error: NSError?) -> Void)
    {
        // Set client ID
        NXOAuth2AuthenticationProvider.setClientId(clientId, scopes: scopes)
        NXOAuth2AuthenticationProvider.sharedAuth()?.redirectURL = "msauth.com.microsoft.ios-swift-faceapi-sample://auth/"
        
        // Try silent log in. This will attempt to sign in if there is a previous successful
        // sign in user information.
        if NXOAuth2AuthenticationProvider.sharedAuth().loginSilent() == true {
            completion(true, nil)
        } else {
            // Otherwise, present log in controller.
            NXOAuth2AuthenticationProvider.sharedAuth().login(with: nil) { (error) in
                    
                    if let nsError = error as NSError? {
                        completion(false, nsError)
                    } else {
                        completion(true, nil)
                    }
            }
        }
    }
    
    func disconnect() {
        NXOAuth2AuthenticationProvider.sharedAuth().logout()
    }
    
    func isConnected() -> Bool
    {
        if NXOAuth2AuthenticationProvider.sharedAuth().loginSilent() == true {
            return true
        } else {
            return false
        }
    }
}
