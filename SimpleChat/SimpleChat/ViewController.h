//
//  ViewController.h
//  SimpleChat
//
//  Created by André Hansson on 2013-10-24.
//  Copyright (c) 2013 PingPal AB. All rights reserved.
//
//  Project home page: https://github.com/PingPal/SimpleChat
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <FBLoginViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
