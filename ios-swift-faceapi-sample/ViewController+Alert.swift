/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

extension UIViewController {
    func alert(title: String?, message: String?, buttonTitle: String = "Close") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(),{
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}
