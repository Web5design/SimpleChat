//
//  AHChatBarView.h
//  ChatBarView
//
//  Created by André Hansson on 2013-09-24.
//  Copyright (c) 2013 André Hansson. All rights reserved.
//
//  Project home page: https://github.com/PingPal/SimpleChat
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

// This is created in the storyboard
// It's the green view

@protocol AHChatBarViewDelegate;

@interface AHChatBarView : UIView <UITextViewDelegate>

@property UITextView *chatTextView;

@property UIButton *sendButton;

@property (nonatomic, assign) IBOutlet id<AHChatBarViewDelegate> delegate;

@end


@protocol AHChatBarViewDelegate <NSObject, UITextViewDelegate>

@optional
- (void)chatBarViewDidPressButton:(NSString *)chatTextViewText;
- (void)chatTextViewDidChange:(UITextView *)textView;
- (void)chatBarView:(AHChatBarView *)chatBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve;
-(void)chatBarViewKeyboardWillShow;
-(void)chatBarViewKeyboardWillHide;

@end