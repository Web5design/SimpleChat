//
//  Message.h
//  SimpleChat
//
//  Created by André Hansson on 2013-10-25.
//  Copyright (c) 2013 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * senderUID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Friend *friend;

@end
