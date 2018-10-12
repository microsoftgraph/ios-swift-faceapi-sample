/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import UIKit

extension UIViewController {
  func alert(title: String?, message: String?, buttonTitle: String = "Close") {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
    DispatchQueue.main.async {
      self.present(alert, animated: true, completion: nil)
    }
  }
}
