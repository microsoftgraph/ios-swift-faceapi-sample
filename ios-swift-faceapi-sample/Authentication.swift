/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation

struct Authentication {
  var authenticationProvider: NXOAuth2AuthenticationProvider?
  {
    get {
      return NXOAuth2AuthenticationProvider.sharedAuth()
    }
  }
}

extension Authentication {
  /**
   Authenticates to Microsoft Graph.
   If a user has previously signed in before and not disconnected, silent log in
   will take place.
   If not, authentication will ask for credentials
   */
  func connectToGraph(withClientId clientId: String,
                      scopes: [String],
                      completion:@escaping (_ result: GraphResult<JSON, NetworkError>) -> Void) {
    
    // Set client ID
    NXOAuth2AuthenticationProvider.setClientId(clientId, scopes: scopes)
    
    // Try silent log in. This will attempt to sign in if there is a previous successful
    // sign in user information.
    if NXOAuth2AuthenticationProvider.sharedAuth().loginSilent() == true {
      completion(.success("" as AnyObject))
    }
      // Otherwise, present log in controller.
    else {
      
      NXOAuth2AuthenticationProvider.sharedAuth()?.login(with: nil, completion: { (error) in
        if let nsError = error {
          completion(.failure(NetworkError.unexpectedError(nsError: nsError as NSError)))
        }
        else {
          completion(.success("" as AnyObject))
        }
      })
    }
  }
  
  func disconnect() {
    NXOAuth2AuthenticationProvider.sharedAuth().logout()
  }
  
  func isConnected() -> Bool {
    if NXOAuth2AuthenticationProvider.sharedAuth().loginSilent() == true {
      return true
    }
    else {
      return false
    }
  }
}
