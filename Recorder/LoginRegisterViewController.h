//
//  LoginRegisterViewController.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 5/16/12.
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
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (strong, nonatomic) IBOutlet UIView *registrationView;

//Login
@property (weak, nonatomic) IBOutlet UITextField *emailLoginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordLoginTextField;
@property (weak, nonatomic) UIBarButtonItem *loginBarButton;
//delegate
@property(weak,nonatomic) id <PopoverDismissDelegate> delegate;


- (IBAction)registerUser:(id)sender;
- (IBAction)loginUser:(id)sender;

- (IBAction)showRegistrationScreen:(id)sender;
- (IBAction)showLoginScreen:(id)sender;

-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
-(void) hideKeyboard;


@end
