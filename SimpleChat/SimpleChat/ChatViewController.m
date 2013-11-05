//
//  ChatViewController.m
//  SimpleChat
//
//  Created by André Hansson on 2013-10-24.
//  Copyright (c) 2013 PingPal AB. All rights reserved.
//

#import "ChatViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "AppDelegate.h"
#import "Message.h"

@interface ChatViewController (){
    NSMutableArray *bubbleData;
    
    NSManagedObjectContext *context;
    
    NSString *myUID;
    
    BOOL indicatorSent;
}

@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;

@end

@implementation ChatViewController

@synthesize bubbleTable, currentFriend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    context = [appDelegate managedObjectContext];
    
    myUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
    
    self.title = currentFriend.name;
    
    // indicatorSent is used to know if the indicator has been sent so we don't send it again and so we know when to send that we are no longer writing.
    indicatorSent = NO;
    
    // Setup the inboxes we  will be needing.
    
    // First one that recives when the other person is writing.
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"%K.writing == 1",PP_KEY_USER_DATA];
    [Outbox addInbox:self andSelector:@selector(dataWriting:) andPredicate:pred];
    
    // And one that recives when the other person stops writing.
    pred = [NSPredicate predicateWithFormat:@"%K.writing == 0",PP_KEY_USER_DATA];
    [Outbox addInbox:self andSelector:@selector(dataNoWriting:) andPredicate:pred];
    
    // And the one that will recive the messages the other person sends.
    pred = [NSPredicate predicateWithFormat:@"%K.message != nil",PP_KEY_USER_DATA];
    [Outbox addInbox:self andSelector:@selector(onInput:) andPredicate:pred];
    
    
    // bubbleTableView
    // To learn more about UIBubbleTableView visit: https://github.com/AlexBarinov/UIBubbleTableView
    bubbleData = [[NSMutableArray alloc] init];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = NO;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [bubbleTable reloadData];
    
    
    // Get all the messages sent to and from the current friend
    
    // Start with a sort descriptor to sort them by date.
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    
    // Create an array with the sorted messages.
    NSArray *sortedMessages = [currentFriend.messages sortedArrayUsingDescriptors:@[sortByDate]];
    
    // Clear bubbleData
    [bubbleData removeAllObjects];
    
    for (Message *message in sortedMessages)
    {
        NSBubbleData *messageBubble;
        
        // Check if the message was sent by me or the other person. 
        if ([myUID isEqualToString:message.senderUID]) {
            
            messageBubble = [NSBubbleData dataWithText:message.text date:message.date type:BubbleTypeMine];
            
        }else{
            
            messageBubble = [NSBubbleData dataWithText:message.text date:message.date type:BubbleTypeSomeoneElse];
            
        }
        
        [bubbleData addObject:messageBubble];
    }
    
    // Reload and scroll to bottom
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
    
    // Get your current ticket. The ticket is used on the server to know witch the latest message you got was.
    NSNumber *ticket = [[NSUserDefaults standardUserDefaults]objectForKey:@"ticket"];
    
    if (ticket != NULL) {
        // The messages will be recived just like they would normaly so they will end up in your onInput selector.
        [Outbox putTo:PP_VALUE_PROTOCOL_PCC message:@{PP_KEY_ACTION:@"fetch", @"ticket":ticket}];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    // Scroll to the bottom.
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // Remove the inboxes and the selectors.
    [Outbox removeInbox:self andSelector:@selector(onInput:)];
    [Outbox removeInbox:self andSelector:@selector(dataWriting:)];
    [Outbox removeInbox:self andSelector:@selector(dataNoWriting:)];
}


-(void)dataWriting:(NSDictionary *)dict
{
    // Show the typingBubble
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
}

-(void)dataNoWriting:(NSDictionary *)dict
{
    // Remove the typingBubble
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:YES];
}

-(void)onInput: (NSDictionary*)dict
{
    NSLog(@"onInput: %@", dict);
    
    NSString *sender = dict[@"from"];

    // Save the new ticket if there is one. 
    NSNumber *ticket = dict[@"ticket"];
    if (ticket != NULL) {
        [[NSUserDefaults standardUserDefaults]setObject:ticket forKey:@"ticket"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    // Makes it easier to access what we need.
    dict = dict[PP_KEY_USER_DATA];
    
    NSString *message = dict[@"message"];
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    // Check if it was the currentFriend that sent the message. 
    if ([currentFriend.uid isEqualToString:sender])
    {
        NSLog(@"sender is currentFriend: %@. Message: %@", sender, message);
        
        NSBubbleData *sayBubble = [NSBubbleData dataWithText:message date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
        
        [bubbleData addObject:sayBubble];
        [bubbleTable reloadData];
        [bubbleTable scrollBubbleViewToBottomAnimated:YES];
        
        // Create a new message object to save.
        Message *newMessage = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        [newMessage setFriend:currentFriend];
        [newMessage setDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [newMessage setText:message];
        [newMessage setSenderUID:sender];
        
        //Save the new message
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error! %@", error);
        }
    }else{
        NSLog(@"sender is NOT currentFriend: %@. Message: %@", sender, message);
        
        // If it wasn't the current friend then we must fetch whoever it was.
        // Create a fetchRequest to get the friend that sent the message
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uid == %@)", sender];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil){
            // Handle the error
            NSLog(@"ERROR: %@", error);
        }
        
        // Create a new message object to save.
        Message *newMessage = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        [newMessage setFriend:[fetchedObjects objectAtIndex:0]];
        [newMessage setDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [newMessage setText:message];
        [newMessage setSenderUID:sender];
    }
}

#pragma mark - AHChatBarViewDelegate

-(void)chatBarViewDidPressButton:(NSString *)chatTextViewText
{
    // Create a bubble for the message
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:chatTextViewText date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    // If your using push you need to specify what you want it to say
    NSString *myName = [[NSUserDefaults standardUserDefaults]objectForKey:@"myName"];
    NSString *pushText = [[NSString alloc]initWithFormat:@"%@: %@",myName,chatTextViewText];
    
    NSDictionary *pushmeta = @{@"alert":pushText,@"sound":@"default",@"badge":@1};
    
    [Outbox putTo:currentFriend.uid message:@{@"message":chatTextViewText} andOptions:@{PP_KEY_PUSH:PP_VALUE_TRUE, PP_KEY_STORE:PP_VALUE_TRUE, PP_KEY_PUSH_META:pushmeta}];
    
    // Create a new message object.
    Message *newMessage = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newMessage setFriend:currentFriend];
    [newMessage setDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [newMessage setText:chatTextViewText];
    [newMessage setSenderUID:myUID];
    
    //Save the new message
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Error! %@", error);
    }
    
    // set to NO because we clear the textView when we send.
    indicatorSent = NO;
}

-(void)chatTextViewDidChange:(UITextView *)textView
{
    // Check if there's any text
    if ([[textView text] length]){
        // Check if the indicator hasn't been sent
        if (!indicatorSent){
            // Send indicator
            indicatorSent = YES;
            [Outbox putTo:currentFriend.uid message:@{@"writing":@(YES)}];
        }
    }else{
        // Sned not writing indicator
        indicatorSent = NO;
        [Outbox putTo:currentFriend.uid message:@{@"writing":@(NO)}];
    }
}

-(void)chatBarView:(AHChatBarView *)chatBarView willChangeFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration animationCurve:(UIViewAnimationCurve)animationCurve{
    
    // Change the frame of the bubbleTable so it's not underneath the keyboard.
    
    CGRect frame = bubbleTable.frame;
    frame.size.height = endFrame.origin.y-20;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options: animationCurve | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [bubbleTable setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         [bubbleTable scrollBubbleViewToBottomAnimated:YES];
                     }];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row{
    return [bubbleData objectAtIndex:row];
}

@end
