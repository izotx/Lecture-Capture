//
//  ViewController.m
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "NetworkHelper.h"
#import "CustomTableButton.h"
#import "Lecture.h"
#import "LectureAPI.h"
#import "IOHelper.h"
#import "WebVideoView.h"
#import "AppDelegate.h"
#import "Slide.h"
@interface ViewController ()
{
   NSMutableArray * compileVideoListArray;
    __weak IBOutlet UITableView *tableView;
    IBOutlet UITableView *compileTableView;
    __weak IBOutlet UIImageView *videoScreenshotImageView;
    __weak IBOutlet UILabel *videoTitleLabel;
    __weak IBOutlet UITextView *videoDescriptionTextView;
    __weak IBOutlet UITextField *editTitleTextField;
    __weak IBOutlet UITextView *editDescriptionTextView;
    __weak IBOutlet UIView *informationAboutRecordingView;
    __weak IBOutlet UIWebView *webView;
    
    CGRect recordingViewFrame;
    NSString* videoPath;
    NSString* titleText;
    Video * currentVideo;
    UIAlertView * uploadAlert;
    UIAlertView * createNewAlert;
    UIAlertView * uploadLogin;
    
    NetworkHelper * networkHelper;
    Manager *manager;

}
- (IBAction)saveToLibrary:(id)sender;
- (IBAction)deleteVideo:(id)sender;
- (IBAction)cancelAndDismissRecordingView:(id)sender;
- (IBAction)contactSupport:(id)sender;
- (void)loadVideoWithURL:(NSURL *) url;
- (void)postMovie:(NSString * )filePath;

@property(nonatomic, strong) LectureAPI *lectureAPI;
@property(nonatomic,strong) IOHelper * iohelper;
@property(nonatomic,strong) WebVideoView *webVideoView;
@end

@implementation ViewController


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView==uploadLogin)
    {
        if(buttonIndex==0)
        {
            [self logInOrOut:_loginBarButton];
            
        }
        else{
            
        }
        
    }
     if(alertView==uploadAlert)
    {
        if(buttonIndex==0)
        {
            //NO?
          
        }
        else{
            [self postMovie:videoPath];
        }
    }
}

#pragma mark files operations

-(void)postMovie:(NSString * )filePath{
if(manager.userId){
    if(filePath.length==0)
    {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to select the video first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
    else{
        NSLog(@"Video Size %f",[currentVideo.video_size floatValue]);
        if([currentVideo.video_size floatValue] > 100 )
        {
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Unfortunately, the selected recording is too large to uplaod it to the server. Currently the file size limit it 100 MB." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
        else{
        // upload video here
            __block UIButton * button = _copyURLButton;
            [networkHelper setCompletionBlocks:^(){
            button.enabled = YES;
              
                
            } andError:^(
             
             ){
            
            }];
            NSLog(@"Trying to upload it");
            [networkHelper uploadVideo:currentVideo andManager:manager andVideoPath:filePath];
        }
    }
}
    else{
        uploadLogin = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to log in in order to upload recordings to the server. Would you like to do it now?" delegate:self cancelButtonTitle:@"Yes, please!" otherButtonTitles:@"No, thanks", nil];
        [uploadLogin show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Executed when Next button is clicked.
   
     if ([segue.identifier isEqualToString:@"Edit"]) {
       RecorderViewController *r = [segue destinationViewController];
       r.lecture =[_fetchedResultsController objectAtIndexPath: [tableView indexPathForSelectedRow]];
         
         
     }
    
    if ([segue.identifier isEqualToString:@"CreateNew"]) {
        RecorderViewController *r = [segue destinationViewController];
        informationAboutRecordingView.frame=CGRectMake(-1024, -800, 0, 0);    
        
        [self textFieldShouldReturn:editTitleTextField];
      //creating new lecture
        NSString *title = (editTitleTextField.text.length>0)?editTitleTextField.text:@"Untitled";
        
        
        Lecture * lecture = [LectureAPI createLectureWithName:title];
        r.lecture = lecture;
        
        
        [self loadVideoWithURL:nil];
    }
     if ([segue.identifier isEqualToString:@"Popover"]) {
         LoginRegisterViewController * r =[segue destinationViewController];
         r.loginBarButton=self.loginBarButton;
       
     }
}

#pragma mark Fetching
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
  
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Lecture" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
  
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
     NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    return _fetchedResultsController;
    
}



#pragma mark uitextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //Array that is storing vidoes
    compileVideoListArray =[[NSMutableArray alloc]initWithCapacity:0];
    networkHelper = [[NetworkHelper alloc]init];
    
    self.uploadingVideoLabel.hidden=YES;
    self.uploadingVideoActivityIndicator.hidden=YES;
    self.movie_url_label.text=@"";
    self.copyURLButton.enabled=NO;

    manager= [Manager sharedInstance];
    manager.logoutDelegate =self;
    videoTitleLabel.text=@"";

    recordingViewFrame =  CGRectMake(0  , 0 , 1024, 748);
    informationAboutRecordingView.frame=CGRectMake(-1024, -800, 0, 0);
    compileTableView.dataSource = self;
    compileTableView.delegate = self;
    
    self.lectureAPI =[LectureAPI new];
    
    [self fetchedResultsController];
    [self loadVideoWithURL:nil];
}

-(void)refactorCoreData{
    //get all videos.
    
    //see if they are assigned to projects.
    
    //

}

#pragma mark notifications and Loading video
- (IBAction)showPreviousSlide:(id)sender {
}

- (IBAction)showNextSlide:(id)sender {
}



- (IBAction)deleteVideo:(id)sender {
    [tableView setEditing:YES animated:YES];
    
    
}

#warning TO DO DELETE THE Load Video url and figure out why the notifications are here
-(void) loadVideoWithURL:(NSURL *) url{
       //url = outputURL;
    
    NSString *videoHTML = [NSString stringWithFormat: @"<html><head><style></style></head><body><video id='video_with_controls' height='%f' width='%f' controls autobuffer autoplay='false'><source src='%@' title='' poster='icon2.png' type='video/mp4' durationHint='durationofvideo'/></video><ul></body></html>",webView.frame.size.height,webView.frame.size.width, url];
    
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    [webView loadHTMLString:videoHTML baseURL:nil];
}



-(void)doneButtonClick:(NSNotification*)aNotification{
    
}


- (void)moviePlaybackChange:(NSNotification *)notification
{

}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerController];
    [moviePlayerController.view removeFromSuperview];


}



#pragma mark table view

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Lecture *lecture =[_fetchedResultsController objectAtIndexPath:indexPath];
    UILabel * titleLabel =  (UILabel *)[cell viewWithTag:10];
    UILabel * durationLabel =  (UILabel *)[cell viewWithTag:20];
    UILabel * fileSizeLabel =  (UILabel *)[cell viewWithTag:30];
    titleLabel.text = lecture.name;

    durationLabel.text=[NSString stringWithFormat:@"Duration: %@",lecture.duration];
    fileSizeLabel.text=[NSString stringWithFormat:@"%@",lecture.size];
    

    CustomTableButton * ctb =  (CustomTableButton  *) [cell viewWithTag:80];
     ctb.indexPath = indexPath;
    [ctb addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)uploadButtonPressed:(id)sender{
   
    CustomTableButton *cb =   (CustomTableButton *)sender;
     NSLog(@"Upload %@ ",cb);

    NSIndexPath *indexPath = [(CustomTableButton *) sender indexPath];
    Video *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    videoPath = info.video_path;
    [self postMovie:videoPath];
}



//reordering the table
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"Object Moved ");

}

- (BOOL)tableView:(UITableView *)_tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView==compileTableView){
    return YES;
    }
    else return NO;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    static NSString *MyIdentifier = @"prototype";
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] ;
     }
  
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if([_tableView isEqual:tableView]){
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

    }
    if([_tableView isEqual:compileTableView]){
        return compileVideoListArray.count;
    }
    return 0;
}
    
- (NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section{
    if([_tableView isEqual:tableView]){
        return @"Recordings";
    }
    if([_tableView isEqual:compileTableView]){
        return @"Compile Video";
    }
        return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
    
      
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
           //  NSLog(@"Insert Rows");
           
            [tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
         
         
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                      
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [tableView reloadData];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [tableView endUpdates];
}


-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if([_tableView isEqual:tableView]){
        // load the first slide
        Lecture * l =[_fetchedResultsController objectAtIndexPath:indexPath];
        if(l.slides.count>0){
            NSSortDescriptor * ns = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
            //[request setSortDescriptors:@[ns]];
            Slide * slide = [[[l.slides allObjects]sortedArrayUsingDescriptors:@[ns]]objectAtIndex:0];
            //load slide
            NSData * data = slide.video;
            if(data){
                NSString * _videoPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [IOHelper  getRandomFilePath]];
                [data writeToFile:_videoPath atomically:YES];
                NSURL* outputURL = [NSURL fileURLWithPath:_videoPath];
                [self loadVideoWithURL:outputURL];
            }
        }

//    videoTitleLabel.text= v.title;
//   [self loadVideoWithURL:outputURL];
//    currentVideo=v;
//    if(v.video_url.length>0){
//        self.movie_url_label.text= v.video_url;
//        self.copyURLButton.enabled=YES;
//    }
//    else{
//        self.movie_url_label.text = @"Tap on the Upload Recording button to upload recording to the server.";
//        self.copyURLButton.enabled=NO;
//    }
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle

forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if([aTableView isEqual:tableView]){
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
        Video * v = [_fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    
        if(context)
        {
            [context deleteObject:v];
        }
        else{
            NSLog(@"Context doesn't exist on delete???");
        
        }
        
        [tableView setEditing:NO animated:YES];
        NSError * error;
      
        [context save:&error];
        
        if(error)
        {
            NSLog(@"%@",[error description]);
        }
        
        [tableView reloadData];
       
    }
   }
}

- (IBAction)editTable:(id)sender {
    if(tableView.editing){
        tableView.editing = NO;
        [sender setTitle:@"Edit"];
    }
    else{
        tableView.editing = YES;
        [sender setTitle:@"Done Editing"];
    }
}



- (IBAction)saveToLibrary:(id)sender {
   
    [_iohelper saveToLibraryFileAtPath:videoPath];
}


- (IBAction)cancelAndDismissRecordingView:(id)sender {
     informationAboutRecordingView.frame=CGRectMake(-1024, -800, 0, 0);

    [self textFieldShouldReturn:editTitleTextField];
}




//Shows the new recording view
- (IBAction)createNewRecording:(id)sender {

    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1];
  
    informationAboutRecordingView.frame=recordingViewFrame;
  
    [UIView commitAnimations];

    [self.view addSubview:informationAboutRecordingView];
    [self.view bringSubviewToFront:informationAboutRecordingView];
    
    NSArray * subviews =informationAboutRecordingView.subviews;
    for (UIView * v in subviews)
    {
        [informationAboutRecordingView bringSubviewToFront:v];
         
    }
}

- (IBAction)shareMovie:(id)sender {
    uploadAlert =[[UIAlertView alloc]initWithTitle:@"Lecture Capture" message:@"You are about to upload video to the remote server in order to obtain a link that you can share with other people. It might be time consuming operation. It's recommended to perform the operation whenever your device is connected to WiFi network. Are you sure that you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [uploadAlert show];
}


- (IBAction)copyURL:(id)sender {
      
    //tableView.selectedRow;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.movie_url_label.text;
    UIAlertView * a =[[UIAlertView alloc]initWithTitle:@"Lecture Capture" message:@"The url of your recording was copied to a clipboard." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [a show];

}



- (IBAction)shareURL:(id)sender {
    NSLog(@"Share URL");
NSString * url= [[UIPasteboard generalPasteboard]string];
if([url length]==0)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" 
                                                    message:@"Select a recording and tap on Copy To ClipBoard first!" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
   
   
}
else if([MFMailComposeViewController canSendMail])
{
 
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Look at this!"];
    url=[NSString stringWithFormat:@"<a href=\%@\">%@</a><br>\n",url,url];
   
    
    NSMutableString *body = [NSMutableString string];
    // add HTML before the link here with line breaks (\n)
    [body appendString:@"<h5>Check this out!</h5>\n"];
    [body appendString:@"Watch a recording using URL given below:<br>\n"];
    [body appendString:url];
    [body appendString:@"Thanks much! <br> \n"];
    [body appendString:@"<a href=\"http://itunes.apple.com/us/app/lecture-capture/id552262316?ls=1&mt=8\">Download a Lecture Capture App</a>\n"];    
    [mailer setMessageBody:body isHTML:YES];

    // only for iPad
     mailer.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:mailer animated:YES completion:nil];

 }
else
{
       NSLog(@"Share URL 3");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:@"Your device doesn't support the composer sheet" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    }
}

- (IBAction)contactSupport:(id)sender {
    if([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Lecture Capture Support"];
        
        NSMutableString *body = [NSMutableString string];
        // add HTML before the link here with line breaks (\n)
        [body appendString:@"<p>Please decribe a problem that you are having with the app. Do you have any suggestions? We will be happy to assist!.</p>\n"];
        [mailer setMessageBody:body isHTML:YES];
        
        // only for iPad
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mailer animated:YES completion:nil];
        
    }
    else
    {
        NSLog(@"Share URL 3");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}




#pragma mark login and login delegate
- (IBAction)logInOrOut:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]; 
    
    if([[self.loginBarButton title] isEqualToString: @"Logout"])
    {
        NSLog(@"Logout ");
        [self.loginBarButton setTitle:@"Login"];
        manager.userId=nil;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" 
                                                        message:@"You were successfully logged out. Tap on the login button to log in again." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];

    }
    else{
        if( self.loginPopOver ==nil)
        {
           LoginRegisterViewController * c= [sb instantiateViewControllerWithIdentifier:@"LoginPopover"];
            
            c.delegate=self;
            c.loginBarButton=self.loginBarButton;
          //  c.preferredContentSize = c.view.frame.size;
            self.loginPopOver=[[UIPopoverController alloc]initWithContentViewController:c];
        
        }    
        if([self.loginPopOver isPopoverVisible])    
        {
            [self.loginPopOver dismissPopoverAnimated:YES];
        }
        else{
           
            [self.loginPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
            
        }
    }
}

-(void)logoutUser{
    [self.loginBarButton setTitle:@"Login"];
}


#pragma mark - MFMailComposeController delegate


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
	  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark popover delegate
-(void)dissmissPopover{
    if(_loginPopOver.isPopoverVisible)
    {
        [_loginPopOver dismissPopoverAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Management s");

}


- (IBAction)editRecording:(id)sender {
    
}




@end
