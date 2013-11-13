//
//  AHChatBarView.m
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

#import "AHChatBarView.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation AHChatBarView
{
    UIColor *iOS7Blue;
    CGFloat keyboardUpY;
    UILabel *placeholderLabel;
    
    CGRect chatBarViewFrame;
    CGRect chatTextViewFrame;
}

- (void)initializator
{
    // Initialization code
    iOS7Blue = [UIColor colorWithRed:(7/255.0) green:(100/255.0) blue:(255/255.0) alpha:1];
    [self setBackgroundColor:[UIColor colorWithWhite:.98 alpha:.98]];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.layer setBorderWidth:.7];
    [self setupTextView];
    [self setupButton];
    
    chatBarViewFrame = self.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)init{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

#pragma mark - TextView

-(void)setupTextView
{
    _chatTextView = [[UITextView alloc]initWithFrame:CGRectMake(7.5, 7.5, self.frame.size.width-80, 35)];
    [_chatTextView setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    _chatTextView.layer.cornerRadius = 4;
    [_chatTextView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [_chatTextView.layer setBorderWidth:.6];
    [_chatTextView setBackgroundColor:[UIColor whiteColor]];
    [_chatTextView setDelegate:self];
    [_chatTextView setReturnKeyType:UIReturnKeyDefault];
    
    _chatTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:_chatTextView];
    
    //TextView placeholder
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, _chatTextView.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:@"ChatApp"];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setFont: [UIFont fontWithName:@"helvetica" size:16]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [_chatTextView addSubview:placeholderLabel];
    
    chatTextViewFrame = _chatTextView.frame;
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_chatTextView.text isEqualToString:@""]) {
        [_sendButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(chatTextViewDidChange:)]) {
        [_delegate chatTextViewDidChange:_chatTextView];
    }
    
    //Placeholder
    if([_chatTextView.text isEqualToString:@""]) {
        [textView addSubview:placeholderLabel];
        [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"Cancel" forState:UIControlStateNormal];
    } else if ([[_chatTextView subviews] containsObject:placeholderLabel]) {
        [placeholderLabel removeFromSuperview];
        [_sendButton setTitleColor:iOS7Blue forState:UIControlStateNormal];
        [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    }
    
    CGRect frame = _chatTextView.frame;
    CGRect viewFrame = self.frame;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        CGRect frameBeforeSizeToFit = _chatTextView.frame;
        [_chatTextView sizeToFit];
        
        CGSize contentSize = _chatTextView.frame.size;
        
        _chatTextView.frame = frameBeforeSizeToFit;
        
        frame.size.height = MIN(contentSize.height, 187);
        
        viewFrame.size.height = MIN(contentSize.height+15, 202);
        
        if (IS_IPHONE_5) {
            viewFrame.origin.y = MAX(keyboardUpY-(contentSize.height+15), 150); //150 iOS 7 statusbar / 130 pre iOS 7 startusbar
        }else{
            viewFrame.origin.y = MAX(keyboardUpY-(contentSize.height+15), 62); //62 iOS 7 statusbar / 42 pre iOS 7 startusbar
        }
        
    }else{
        
        frame.size.height = MIN(_chatTextView.contentSize.height, 187);
        
        viewFrame.size.height = MIN(_chatTextView.contentSize.height+15, 202);
        
        if (IS_IPHONE_5) {
            viewFrame.origin.y = MAX(keyboardUpY-(_chatTextView.contentSize.height+15), 130);
        }else{
            viewFrame.origin.y = MAX(keyboardUpY-(_chatTextView.contentSize.height+15), 42);
        }
    }
    
    [UIView animateWithDuration:0.17
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = viewFrame;
                         _chatTextView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [_chatTextView setFrame:chatTextViewFrame];
    
    if ([_chatTextView.text isEqualToString:@""])
    {
        [_chatTextView addSubview:placeholderLabel];
        [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    }
}


#pragma mark - Button

-(void)setupButton
{
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setFrame:CGRectMake(self.frame.size.width-65, self.frame.size.height-35-7.5, 60, 35)];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:_sendButton];
}

- (void)sendButtonClicked:(id)sender
{
    if (![_chatTextView.text isEqualToString: @""])
    {
        
        if ([_delegate respondsToSelector:@selector(chatBarViewDidPressButton:)]){
            [_delegate chatBarViewDidPressButton:_chatTextView.text];
        }
        
        _chatTextView.text = @"";
    }
    
    [_chatTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([_chatTextView isFirstResponder])
    {
        chatBarViewFrame = self.frame;
        
        if ([_delegate respondsToSelector:@selector(chatBarViewKeyboardWillShow)]) {
            [_delegate chatBarViewKeyboardWillShow];
        }
        
        CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            keyboardEndFrame.origin.y -= 20;    // If your not using iOS 7 status bar.
        }
        
        if ([[UIApplication sharedApplication] statusBarFrame].size.height == 40) {
            keyboardEndFrame.origin.y -= 20;   // If the in-call statusBar is present.
        }
        
        keyboardUpY = keyboardEndFrame.origin.y;
        
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        UIViewAnimationCurve keyboardTransitionAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
        
        CGRect frame = self.frame;
        frame.origin.y = keyboardEndFrame.origin.y-frame.size.height;
        
        if ([_delegate respondsToSelector:@selector(chatBarView:willChangeFromFrame:toFrame:duration:animationCurve:)]) {
            [_delegate chatBarView:self willChangeFromFrame:self.frame toFrame:frame duration:animationDuration animationCurve:keyboardTransitionAnimationCurve];
        }
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options: keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.frame = frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([_chatTextView isFirstResponder])
    {
        
        if ([_delegate respondsToSelector:@selector(chatBarViewKeyboardWillHide)]) {
            [_delegate chatBarViewKeyboardWillHide];
        }
        
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        UIViewAnimationCurve keyboardTransitionAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
        
        if ([_delegate respondsToSelector:@selector(chatBarView:willChangeFromFrame:toFrame:duration:animationCurve:)]) {
            [_delegate chatBarView:self willChangeFromFrame:self.frame toFrame:chatBarViewFrame duration:animationDuration animationCurve:keyboardTransitionAnimationCurve];
        }
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options: keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.frame = chatBarViewFrame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end