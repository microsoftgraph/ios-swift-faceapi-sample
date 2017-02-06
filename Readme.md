#Microsoft Cognitive Services with Graph SDK Sample for iOS

This sample shows how to use both the [Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios) and the [Microsoft Cognitive Services Face API](https://www.microsoft.com/cognitive-services/en-us/face-api) in an iOS app. 
The user can select a photo locally from the device or from a user profile stored in Microsoft Exchange or Outlook. The sample uses the Face API to detect and identify the person in the photo.

The sample code shows how to do the following:

- Retrieve a user profile picture from the Office 365 directory of the signed-in user by using Microsoft Graph.
- Create person group, add a person to the person group, train a person group, detect faces, and identify faces.

![PhotoSelection](/readme-images/photoSelection.png) ![PhotoIdentification](/readme-images/photoIdentification.png)
## Prerequisites
* [Xcode](https://developer.apple.com/xcode/downloads/) version 7.3.1 from Apple
* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)  as a dependency manager.
* A Microsoft work account such as Office 365.  You can sign up for [an Office 365 Developer subscription](https://profile.microsoft.com/RegSysProfileCenter/wizardnp.aspx?wizid=14b845d0-938c-45af-b061-f798fbb4d170&lcid=1033) that includes the resources that you need to start building Office 365 apps.

> Note: This sample relies on the user having an organizational account with a profile picture set in Microsoft Exchange or applied in the user's Outlook profile. If a profile picture is not present in either location, you'll see an error when the sample tries to retrieve the picture.

* A client id for an app registered at the [Application Registration Portal](https://apps.dev.microsoft.com). On this site click **Go to app list.** From here you can add an app. Be sure to add the **Mobile** platform and copy the Client Id, which you'll use when you follow the steps in the **Running this sample in Xcode** section below.

* A subscription key for Cognitive Services. Check out services provided by [Microsoft Cognitive Services](https://www.microsoft.com/cognitive-services). Be sure to add a key for the Face API. You'll need to use that key value when you follow the steps in the **Running this sample in Xcode** section below.

>**Note:** The sample was tested on Xcode 7.3.1. This sample does not yet support Xcode 8 and iOS10, which uses the Swift 3.0 framework.

## Running this sample in Xcode

1. Clone or download this repository.
2. Use CocoaPods to import the SDK dependencies. This sample app already contains a podfile that will get the pods into the project. Simply navigate to the project root from **Terminal** and run:

        pod install

  	 For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)

3. Open **ios-swift-faceAPIs-with-Graph.xcworkspace**
4. Open the **Application/ApplicationConstants.swift** file. 
You'll see placeholder values for **Client ID** and **Subscription key** for Cognitive Services in the ApplicationConstants struct. Replace these placeholders with the Client Id of the app you registered and your Cognitive Services subscription key.
For this sample, scopes for Graph have been pre-defined for you.
   ```swift
    // Graph information
    static let clientId = "ENTER_CLIENT_ID"
    static let scopes   = ["https://graph.microsoft.com/User.Read",
                           "offline_access"]
    
    // Cognitive services information
    static let ocpApimSubscriptionKey = "ENTER_SUBSCRIPTION_KEY"
   ```
5. Run the sample. You'll be asked to connect/authenticate to a work account and you'll need to provide your Office 365 credentials. Once authenticated you'll be taken to the photo selector controller to select a person to identify and a photo to identify from. 

##Code of Interest

#### Graph
This sample contains two Microsoft Graph calls, both of which are in **Graph.swift** file under /Graph.

1. Get user's directory
   ```swift
    func getUsers(with completion: (result: GraphResult<[MSGraphUser], Error>) -> Void) {
        graphClient.users().request().getWithCompletion {
            (userCollection: MSCollection?, next: MSGraphUsersCollectionRequest?, error: NSError?) in
		...
            }
        }
    }
   ```
   
2. Get user profile (photo value)
   ```swift
 func getPhotoValue(forUser upn: String, with completion: (result: GraphResult<UIImage, Error>) -> Void) {
        graphClient.users(upn).photoValue().downloadWithCompletion {
            (url: NSURL?, response: NSURLResponse?, error: NSError?) in
       ...
		}
 }
   ```

#### Cognitive Services - Face API
This sample shows the basics of using the Microsoft Cognitive Services Face API to detect and identify faces. For more information, please visit [Microsoft Face API](https://www.microsoft.com/cognitive-services/en-us/face-api/documentation/overview)

The code for identifying faces from scratch and related functions are in the **FaceAPI.swift** file under /CognitiveServices and the **FaceApiTableViewController.swift** file under /Controllers.

These are the steps taken by the code:

1. Create person group. You can find the person group's name in the **FaceApiTableViewController.swift** file.
2. Create person in the new person group.

   (The person must be created within the group before uploading face(s) and training.)
3. Upload person's face.
4. Train person group.
5. Check & wait for the completion of training.

   This should take only a few seconds. Poll until it is complete and then proceed to the next step.
6. Detect faces.
7. Identify faces in the person group.

> Note: This sample uses a single photo for training. In real-life scenarios, it would be advisable to use more than one photo for better accuracy. Also, this sample will create a person group as well as persons within that group. If you want to delete it, refer to  [delete](https://dev.projectoxford.ai/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395245) api. 

## Questions and comments

We'd love to get your feedback about the Microsoft Graph SDK Profile Picture Sample. You can send your questions and suggestions to us in the [Issues](https://github.com/microsoftgraph/ios-swift-faceapi-sample/issues) section of this repository.

Questions about Microsoft Graph development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [MicrosoftGraph].

## Contributing
You will need to sign a [Contributor License Agreement](https://cla.microsoft.com/) before submitting your pull request. To complete the Contributor License Agreement (CLA), you will need to submit a request via the form and then electronically sign the CLA when you receive the email containing the link to the document.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Additional resources

* [Microsoft Graph overview page](https://graph.microsoft.io)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.

