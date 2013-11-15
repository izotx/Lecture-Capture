//
//  LoginRegisterViewController.h
//  Lecture Capture
//
//  Created by DJMobile INC on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manager.h"
@protocol PopoverDismissDelegate <NSObject>
-(void)dissmissPopover;

@end


@interface LoginRegisterViewController : UIViewController<LoginDelegate, RegisterDelegate, UITextFieldDelegate>
{
    Manager * manager;
    NSArray * textFields;
}
//Register
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (strong, nonatomic) IBOutlet UIView *registrationView;

//Login
@property (strong, nonatomic) IBOutlet UITextField *emailLoginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordLoginTextField;
@property (strong, nonatomic) UIBarButtonItem *loginBarButton;
//delegate
@property(weak,nonatomic) id <PopoverDismissDelegate> delegate;


- (IBAction)registerUser:(id)sender;
- (IBAction)loginUser:(id)sender;

- (IBAction)showRegistrationScreen:(id)sender;
- (IBAction)showLoginScreen:(id)sender;

-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
-(void) hideKeyboard;



@end
