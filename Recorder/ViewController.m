//
//  ViewController.m
//  Recorder
//
//  Created by Janusz Chudzynski on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "NetworkHelper.h"
#import "CustomTableButton.h"


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
    NSFetchedResultsController * fetchedResultsController;
    NSString* videoPath;
    NSString* titleText;
    Video * currentVideo;
    UIAlertView * uploadAlert;
    UIAlertView * createNewAlert;
    NetworkHelper * networkHelper;
    Manager *manager;
    
}
- (IBAction)saveToLibrary:(id)sender;
- (IBAction)deleteVideo:(id)sender;
- (IBAction)cancelAndDismissRecordingView:(id)sender;
- (IBAction)contactSupport:(id)sender;
- (void)loadVideoWithURL:(NSURL *) url;
- (void)postMovie:(NSString * )filePath;

@property(nonatomic,retain)NSFetchedResultsController * fetchedResultsController;
@property(nonatomic, assign) BOOL bannerIsVisible;
@property(nonatomic,strong) MPMoviePlayerController *globalMoviePlayerController;

@end

@implementation ViewController

@synthesize bannerView = _bannerView;
@synthesize uploadingVideoActivityIndicator = _uploadingVideoActivityIndicator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize movie_url_label = _movie_url_label;
@synthesize copyURLButton;
@synthesize loginBarButton = _loginBarButton;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize loginPopOver;
@synthesize uploadingVideoLabel = _uploadingVideoLabel;
@synthesize bannerIsVisible;

#pragma  mark iAD
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, +banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;        
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
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


-(void)deleteFileAtPath:(NSString *)path{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error;
    if( [fm fileExistsAtPath:path])
    {
        [fm removeItemAtPath:path error:&error];
    }
    if(error)
    {
        NSLog(@"Error %@ ",[error debugDescription]);
    }
    else{
        NSLog(@"File %@ deleted",path);
    }
}


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
        
            [networkHelper setCompletionBlocks:^(){
                
            } andError:^(){
            
            }];
            [networkHelper uploadVideo:currentVideo andManager:manager andVideoPath:filePath];
        }
    }
}
    else{
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to log in in order to upload recordings to the server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Executed when NExt button is clicked.
    
    if ([segue.identifier isEqualToString:@"Modal"]) {
        RecorderViewController *r = [segue destinationViewController];
        
        informationAboutRecordingView.frame=CGRectMake(-1024, -800, 0, 0);    
        [self textFieldShouldReturn:editTitleTextField];
        
        if(editTitleTextField.text.length>0)
        {
            r.movie_title=editTitleTextField.text;
            NSLog(@"Movie title is %@",r.movie_title);
        }
        else{
            r.movie_title=@"Untitled";
        } 
        r.managedObjectContext=self.managedObjectContext;
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
                                   entityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
  
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"title" ascending:YES];
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
    manager= [Manager sharedManager];
    manager.logoutDelegate =self;
     videoTitleLabel.text=@"";
    self.movie_url_label.text=@"";
  
    self.bannerIsVisible=NO;
    self.copyURLButton.enabled=NO;
	// Do any additional setup after loading the view, typically from a nib.
    recordingViewFrame =  CGRectMake(0  , 0 , 1024, 748);
    informationAboutRecordingView.frame=CGRectMake(-1024, -800, 0, 0);
    compileTableView.dataSource = self;
    compileTableView.delegate = self;
    
    [self fetchedResultsController];
    [self loadVideoWithURL:nil];
}

-(void)refactorCoreData{
    //get all videos.
    
    //see if they are assigned to projects.
    
    //

}

#pragma mark notifications and Loading video
- (void)video:(NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString * message;
    if(error)
    {
        NSLog(@"didFinishSavingWithError: %@", error);
        message= [NSString stringWithFormat: @"Error. %@",[error localizedDescription]];
    }
    else{
        message=@"Movie was successfully saved. It can be accessed from Photos App.";
    }
    UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [al show];
    
}



- (IBAction)deleteVideo:(id)sender {
    [tableView setEditing:YES animated:YES];
    
    
}


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
    Video *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    UILabel * titleLabel =  (UILabel *)[cell viewWithTag:10];
    UILabel * durationLabel =  (UILabel *)[cell viewWithTag:20];
    UILabel * fileSizeLabel =  (UILabel *)[cell viewWithTag:30];
    titleLabel.text=info.title;
    durationLabel.text=[NSString stringWithFormat:@"Duration: %@",info.duration];
    fileSizeLabel.text=info.video_size;
    CustomTableButton * ctb =  (CustomTableButton  *) [cell viewWithTag:80];
    ctb.indexPath = indexPath;
    [ctb addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)uploadButtonPressed:(id)sender{
   
    CustomTableButton *cb =   (CustomTableButton *)sender;
     NSLog(@" %@ ",cb);
    //   Video * v =
    NSIndexPath *indexPath = [(CustomTableButton *) sender indexPath];
    Video *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    videoPath = info.video_path;
    [self postMovie:videoPath];
}



//reordering the table
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"Object Moved ");

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==compileTableView){
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
   // DebugLog(@" Will Change");
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
    NSLog(@"Did Select");
    if([_tableView isEqual:tableView]){
    Video * v = [_fetchedResultsController objectAtIndexPath:indexPath];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:v.video_path])
    {
        videoPath =v.video_path;
    }
    else{
        videoPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], v.video_path];
    }
    
 	NSURL* outputURL = [NSURL fileURLWithPath:videoPath];
    
    videoTitleLabel.text= v.title;
   [self loadVideoWithURL:outputURL];
    currentVideo=v;
    if(v.video_url.length>0){
        self.movie_url_label.text= v.video_url;
        self.copyURLButton.enabled=YES;
    }
    else{
        self.movie_url_label.text = @"Tap on the Upload Recording button to upload recording to the server.";
        self.copyURLButton.enabled=NO;
    }
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
        [context deleteObject:v];
        if(context)
        {
        
        }
        else{
            NSLog(@"Context doesn't exist on delete???");
        
        }
        
        [tableView setEditing:NO animated:YES];
        NSError * error;
        [self deleteFileAtPath:v.video_path];
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

#pragma  mark Compiling Video
- (IBAction)addToSmallTable:(id)sender {
  //Configure table
    [compileTableView setEditing:YES];
    
    //Get the current video from the big table
   NSLog(@"%@ ",(CustomTableButton *) sender);
   NSIndexPath *indexPath = [(CustomTableButton *) sender indexPath];
   Video *info = [_fetchedResultsController objectAtIndexPath:indexPath];

    NSLog(@" Adding video inside a small table... %@ indexPath %@ ",indexPath, _fetchedResultsController);
    if(info){
        [compileVideoListArray addObject: info];
    }
    

    
    [compileTableView reloadData];
    

}


- (IBAction)saveToLibrary:(id)sender {
  
    if(videoPath.length>0)
    {
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    }
    else
    {
        NSString * message=@"You need to select a movie from the list.";
        UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [al show];

    }
  
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
                            NSLog(@"Nil ");
            LoginRegisterViewController * c=[sb instantiateViewControllerWithIdentifier:@"LoginPopover"];
            c.delegate=self;
            c.loginBarButton=self.loginBarButton;
            self.loginPopOver=[[UIPopoverController alloc]initWithContentViewController:c];
        
        }    
        if([self.loginPopOver isPopoverVisible])    
        {
            [self.loginPopOver dismissPopoverAnimated:YES];
        }
        else{
            [self.loginPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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
    if(loginPopOver.isPopoverVisible)
    {
        [loginPopOver dismissPopoverAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Management s");

}

@end
