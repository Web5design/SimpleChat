//
//  AHChatBarView.h
//  ChatBarView
//
//  Created by André Hansson on 2013-09-24.
//  Copyright (c) 2013 André Hansson. All rights reserved.
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