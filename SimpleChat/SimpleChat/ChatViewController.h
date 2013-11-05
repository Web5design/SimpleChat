//
//  ChatViewController.h
//  SimpleChat
//
//  Created by André Hansson on 2013-10-24.
//  Copyright (c) 2013 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "AHChatBarView.h"
#import "Friend.h"

@interface ChatViewController : UIViewController <UIBubbleTableViewDataSource, AHChatBarViewDelegate>

// The friend you're currently chating with
@property Friend *currentFriend;

@end
