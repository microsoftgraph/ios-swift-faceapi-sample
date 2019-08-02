---
page_type: sample
products:
- office-365
- ms-graph
languages:
- swift
extensions:
  contentType: samples
  technologies:
  - Microsoft Graph
  services:
  - Office 365
  - Users
  platforms:
  - iOS
  createdDate: 9/8/2016 11:27:52 AM
---
# Microsoft Cognitive Services with Graph SDK Sample for iOS

This sample shows how to use both the [Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios) and the [Microsoft Cognitive Services Face API](https://www.microsoft.com/cognitive-services/en-us/face-api) in an iOS app.
The user can select a photo locally from the device or from a user profile stored in Microsoft Exchange or Outlook. The sample uses the Face API to detect and identify the person in the photo.

The sample code shows how to do the following:

- Retrieve a user profile picture from the Office 365 directory of the signed-in user by using Microsoft Graph.
- Create person group, add a person to the person group, train a person group, detect faces, and identify faces.

![PhotoSelection](/readme-images/photoSelection.png) ![PhotoIdentification](/readme-images/photoIdentification.png)

## Prerequisites

- [Xcode](https://developer.apple.com/xcode/downloads/) version 10.2.1
- Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) as a dependency manager.
- A Microsoft work or school account.  You can sign up for [an Office 365 Developer subscription](https://profile.microsoft.com/RegSysProfileCenter/wizardnp.aspx?wizid=14b845d0-938c-45af-b061-f798fbb4d170&lcid=1033) that includes the resources that you need to start building Office 365 apps.

    > Note: This sample relies on the user having an organizational account with a profile picture set in Microsoft Exchange or applied in the user's Outlook profile. If a profile picture is not present in either location, you'll see an error when the sample tries to retrieve the picture.

- A subscription key for Cognitive Services. Check out services provided by [Microsoft Cognitive Services](https://www.microsoft.com/cognitive-services). Be sure to add a key for the Face API. You'll need to use that key value when you follow the steps in the **Running this sample in Xcode** section below.

## Register and configure the app

1. Open a browser and navigate to the [Azure Active Directory admin center](https://aad.portal.azure.com) and login using a **personal account** (aka: Microsoft Account) or **Work or School Account**.

1. Select **Azure Active Directory** in the left-hand navigation, then select **App registrations** under **Manage**.

1. Select **New registration**. On the **Register an application** page, set the values as follows.

    - Set **Name** to `Swift Face API Sample`.
    - Set **Supported account types** to **Accounts in any organizational directory and personal Microsoft accounts**.
    - Under **Redirect URI**, change the drop down to **Public client (mobile & desktop)**, and set the value to `msauth.com.microsoft.ios-swift-faceapi-sample://auth`.

1. Choose **Register**. On the **Swift Face API Sample** page, copy the value of the **Application (client) ID** and save it, you will need it in the next step.

## Running this sample in Xcode

1. Clone or download this repository.
1. Use CocoaPods to import the SDK dependencies. This sample app already contains a podfile that will get the pods into the project. Simply navigate to the project root from **Terminal** and run:

    ```Shell
    pod install
    ```

1. Open **ios-swift-faceAPIs-with-Graph.xcworkspace**.
1. Open the **Application/ApplicationConstants.swift** file. Replace `YOUR CLIENT ID` with the application ID of your app registration.
1. Replace `ENTER_SUBSCRIPTION_KEY` with your Face API key.
1. Replace `YOUR_FACE_API_ENDPOINT` with the endpoint for your Face API cognitive service. See the [Azure documentation](https://docs.microsoft.com/azure/cognitive-services/face/quickstarts/curl#face-endpoint-url) for details.
1. Run the sample. You'll be asked to connect/authenticate to a work account and you'll need to provide your Office 365 credentials. Once authenticated you'll be taken to the photo selector controller to select a person to identify and a photo to identify from.

## Code of Interest

### Graph

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

### Cognitive Services - Face API

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

## Copyright

Copyright (c) 2016 Microsoft. All rights reserved.
