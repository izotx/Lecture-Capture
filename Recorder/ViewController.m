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
#import "PDF.h"

#import "LectureAPI.h"
#import "AppDelegate.h"
#import "Slide.h"
#import "PDFImporterViewController.h"
#import "RecordingOperationsViewController.h"
#import "AbstractCell.h"

@interface ViewController ()
{
    __weak IBOutlet UITableView *tableView;
    UIAlertView * createNewAlert;
    UIAlertView * uploadLogin;
    Manager *manager;
}

- (IBAction)contactSupport:(id)sender;
- (IBAction)showLectures:(id)sender;
- (IBAction)showPDF:(id)sender;


@property (strong, nonatomic) IBOutlet UIView *container;
@property(nonatomic, strong) LectureAPI *lectureAPI;
@property(nonatomic,strong) PDFImporterViewController * importer;
@property (nonatomic,strong) RecordingOperationsViewController * recordingOperations;

@end

@implementation ViewController

- (IBAction)contentTypeSegmentedControlChanged:(id)sender {
    if( [(UISegmentedControl * )sender selectedSegmentIndex] == 0){
        //load lecture
        [self showLectures:nil];
    }
    else{
        [self showPDF:nil];
    }
}

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
  }

#pragma mark files operations



- (IBAction)showLectures:(id)sender {
  self.fetchedResultsController =  [self prepareLectureFetchedResultsController];
    [tableView reloadData];
}

- (IBAction)showPDF:(id)sender {
    self.fetchedResultsController = [self preparePDFFetchedResultsController];
        [tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Executed when Next button is clicked.
   
     if ([segue.identifier isEqualToString:@"Edit"]) {
       RecorderViewController *r = [segue destinationViewController];
       r.lecture =[_fetchedResultsController objectAtIndexPath: [tableView indexPathForSelectedRow]];
     }
    
    if ([segue.identifier isEqualToString:@"Create"]) {
        RecorderViewController *r = [segue destinationViewController];
        
        Lecture * lecture = [LectureAPI createLectureWithName:@"Untitled"];
        r.lecture = lecture;

    }
     if ([segue.identifier isEqualToString:@"Popover"]) {
         LoginRegisterViewController * r =[segue destinationViewController];
         r.loginBarButton=self.loginBarButton;
       
     }
}

#pragma mark Fetching
- (NSFetchedResultsController *)prepareLectureFetchedResultsController {
    
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
                                                   cacheName:nil];
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

- (NSFetchedResultsController *)preparePDFFetchedResultsController {
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"PDF" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"filename" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
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

    [self showLectures:nil];
    manager= [Manager sharedInstance];
    manager.logoutDelegate =self;
    self.lectureAPI =[LectureAPI new];
    [self showLectures:nil];
}



-(void)refactorCoreData{
    //get all videos.
    
    //see if they are assigned to projects.
    
    //
}

#pragma mark notifications and Loading video

- (IBAction)deleteVideo:(id)sender {
    [tableView setEditing:YES animated:YES];
}



#pragma mark table view

//reordering the table
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
   

}

- (BOOL)tableView:(UITableView *)_tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   return NO;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AbstractCell *cell;
    static NSString *LectureIdentifier = @"lectureCell";
    static NSString *PDFIdentifier = @"pdfCell";
    
    id object  =[self.fetchedResultsController objectAtIndexPath:indexPath] ;
    
    if([object isKindOfClass:[PDF class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:PDFIdentifier];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:LectureIdentifier];
    }
    
    NSDictionary *ob = @{@"object":object,@"super":self};
    
    [cell configureCellWithObject:ob atIndexPath:indexPath];

    return cell;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if([_tableView isEqual:tableView]){
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    }
      return 0;
}
    
- (NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section{
    if([_tableView isEqual:tableView]){
        return @"Recordings";
    }
        return @"PDFs";
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
           
            [tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
         
         
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                      
            break;
            
        case NSFetchedResultsChangeUpdate:
            

            [tableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
            
           

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
// depending on object
id object =[_fetchedResultsController objectAtIndexPath:indexPath];
    if([object isKindOfClass:[Lecture class]]){
        object = (Lecture *)object;
        Lecture * l =[_fetchedResultsController objectAtIndexPath:indexPath];
       
     //   if(!_recordingOperations){
            self.recordingOperations = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordingOperationsViewController"];
       // }
        [_recordingOperations removeFromParentViewController];
        
        _recordingOperations.lecture = l;
     [self displayContentController:_recordingOperations];
    }
    if([object isKindOfClass:[PDF class]]){
//        if(!_importer){
            self.importer=[self.storyboard instantiateViewControllerWithIdentifier:@"PDFImporterViewController"];
  //      }
         _importer.pdf =object;
        [self displayContentController:_importer];
    }
}

- (void) displayContentController: (UIViewController*) content;

{
    
    
    [self addChildViewController:content];                 // 1
    [content view];
    content.view.frame = self.container.frame; // 2
    
    [self.view addSubview:content.view];
    
    [content didMoveToParentViewController:self];          // 3
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle

forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
        
    {
       NSManagedObject *object = [_fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    
        if(context)
        {
            [context deleteObject:object];
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



- (IBAction)contactSupport:(id)sender {
#warning implement

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




@end
