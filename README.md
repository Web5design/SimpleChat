How to install: 

Download the project.

You need to download the latest Facebook iOS SDK and add it to the project. Download it here: https://developers.facebook.com/docs/ios/. 
You double click the .pkg file you get to install it. This adds a FacebookSDK folder in you documents folder. In the FacebookSDK folder you find the FacebookSDK.framwork which you then add to the project.  
All the code to implement the Facebook SDK is already there and it's already connected to a Facebook app.

Next you need to sign up on http://pingpal.io/ for a free developer account. From your developer dashboard you can download the iOS BETA SDK which you will need to add to the project just like you did with the Facebook SDK. All the code is already done.

The last thing to do is to create an app on the developer dashboard. Name it whatever you want. Then you need to copy the apps App ID and Secret and paste them in the AppDelegate.m file in the project. 


And thats it. 


If you want to add push notifications to the app you need to upload a push development certificate on you developer dashboard on http://pingpal.io/. 

Here is a guide on how to create your certificate: http://pingpal.io/resources/documentation/ios-push-certificate-quick-guide/


We use Axel Barinov's UIBubbleTableView in this project. https://github.com/AlexBarinov/UIBubbleTableView

This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
