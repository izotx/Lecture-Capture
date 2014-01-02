//
//  ViewController.h
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecorderViewController.h"
#import "Manager.h"
#import "LoginRegisterViewController.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, PopoverDismissDelegate, LogoutDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginBarButton;
@property(strong, nonatomic) UIPopoverController* loginPopOver;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadingVideoActivityIndicator;
@property(nonatomic,retain)NSFetchedResultsController * fetchedResultsController;
- (IBAction)logInOrOut:(id)sender;
- (IBAction)editTable:(id)sender;


@end
