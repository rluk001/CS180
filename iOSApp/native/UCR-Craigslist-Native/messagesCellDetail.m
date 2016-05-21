//
//  messagesCellDetail.m
//  UCR-Craigslist-Native
//
//  Created by Michael Chen on 5/20/16.
//  Copyright © 2016 UCR. All rights reserved.
//

#import "messagesCellDetail.h"
#import "messages.h"
#import "loginPage.h"
#import "dbArrays.h"
#import "users.h"
#import "messagesCellDetail.h"

@interface messagesCellDetail ()

@end

@implementation messagesCellDetail
@synthesize message, navBarItem, currentLoggedInUserName, num_messages_label, barButtonItem, composeField, sendButtonItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    composeField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 310, 32)];
    UIBarButtonItem * textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:composeField];


    self.toolbarItems= @[textFieldItem];
    NSMutableArray * newItems = [self.toolbarItems mutableCopy];
    [newItems addObject:sendButtonItem];
    self.toolbarItems = newItems;
    
    // keyboard listener http://stackoverflow.com/questions/30879903/move-uitoolbar-with-keyboard-ios8
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //keyboard dismiss: http://stackoverflow.com/a/5711504
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    num_messages_label.userInteractionEnabled = false;
    self.navigationController.toolbarHidden = false;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)dismissKeyboard { //http://stackoverflow.com/a/5711504
    [composeField resignFirstResponder];
}

// move toolbar up and down http://stackoverflow.com/questions/30879903/move-uitoolbar-with-keyboard-ios8
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* keyboardInfo = [aNotification userInfo];
    
    // the keyboard is showing so resize the table's height
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //kbSize: http://www.idev101.com/code/User_Interface/keyboard.html
    CGSize kbSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize.height: %f", kbSize.height);
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];

    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x,
                                                           self.navigationController.toolbar.frame.origin.y - 162.0,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary* keyboardInfo = [aNotification userInfo];
    
    //kbSize: http://www.idev101.com/code/User_Interface/keyboard.html
    CGSize kbSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize.height: %f", kbSize.height);
    
    // the keyboard is hiding reset the table's height
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //frame.origin.y += self.navigationController.toolbar.frame.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x,
                                                           self.navigationController.toolbar.frame.origin.y + 162.0,
                                                           self.navigationController.toolbar.frame.size.width,
                                                           self.navigationController.toolbar.frame.size.height)];
    
    [UIView commitAnimations];
}

- (IBAction)sendButton:(id)sender{
    //write to the db
    NSLog(@"composeField.text: %@", composeField.text);
    [composeField setText:@""];
    
    
    //after written
    //refresh db retreival
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    //[composeField becomeFirstResponder];
    //[self.view addSubview:composeField];
    //[self.view bringSubviewToFront:composeField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self findRelevantMessages].count;
}

-(NSMutableArray*)findRelevantMessages{
    users * userObj;
    messages * messageObj;
    
    NSMutableArray * relevantMessagesArray = [NSMutableArray new];
    NSString * currentLoggedInUserID;
    
    for(int i  = 0; i < [dbArrays sharedInstance].usersArray.count; i++){
        userObj = [[dbArrays sharedInstance].usersArray objectAtIndex:i];
        NSLog(@"userObj.loggedIn: %@", userObj.loggedIn);
        if([userObj.loggedIn isEqualToString:@"true"]){
            currentLoggedInUserName = userObj.username;
            currentLoggedInUserID = userObj.userID;
        }
    }
    
    for(int i = 0; i < [dbArrays sharedInstance].messagesArray.count; i++){
        messageObj = [[dbArrays sharedInstance].messagesArray objectAtIndex:i];
        
        if(([messageObj.message_receiver isEqualToString:currentLoggedInUserName] && [messageObj.message_sender isEqualToString:message.message_sender]) || ([messageObj.message_sender isEqualToString:currentLoggedInUserName] && [messageObj.message_receiver isEqualToString:message.message_sender])){
            NSLog(@"message ADDED!!!!!!!!!!!!!!!!!");
            NSLog(@"messageObj.message_id: %@", messageObj.message_id);
            NSLog(@"messageObj.message_sender: %@", messageObj.message_sender);
            NSLog(@"messageObj.message_receiver: %@", messageObj.message_receiver);
            NSLog(@"messageObj.message_content: %@", messageObj.message_content);
            NSLog(@"messageObj.message_timesent: %@", messageObj.message_timesent);
            NSLog(@"messageObj.message_date: %@", messageObj.message_date);
            NSLog(@"messageObj.message_seen: %@", messageObj.message_seen);
            [relevantMessagesArray addObject:messageObj];
        }
    }
    
    //set title
    navBarItem.title = message.message_sender;
    
    //set num of messages label here
    if(relevantMessagesArray.count == 1){
         num_messages_label.text = @"1 message";
    }
    else{
        num_messages_label.text = [NSString stringWithFormat:@"%lu messages", (unsigned long)relevantMessagesArray.count];
    }
    
    return relevantMessagesArray;
}

-(void)getMessages:(id)_message{
    message = _message;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    
    messages * message_output;
    message_output = [[self findRelevantMessages] objectAtIndex:indexPath.row];
    NSString * timeStamp = [NSString stringWithFormat:@"%@ on %@", message_output.message_timesent, message_output.message_date];
    if([message_output.message_sender isEqualToString:currentLoggedInUserName]){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"you @ %@", timeStamp];
    }
    else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ @ %@", message_output.message_sender, timeStamp];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", message_output.message_content];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end