//
//  LoginRegisterViewController.m
//  Lecture Capture
//
//  Created by DJMobile INC on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginRegisterViewController.h"

@interface LoginRegisterViewController ()

@end

@implementation LoginRegisterViewController

@synthesize registrationView;
@synthesize emailLoginTextField;
@synthesize passwordLoginTextField;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize confirmPasswordTextField;
@synthesize displayNameTextField;
@synthesize loginBarButton;
@synthesize delegate;

#pragma mark login and registration delegate methods
-(void)loginSuccess{
    //Move User to different screen
    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You were successfully logged In." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [a show];
    [self.loginBarButton setTitle:@"Logout"];
    [self.delegate dissmissPopover];
    
    NSLog(@"Success");

}

-(void)loginFailedWithMessage:(NSString *)message{
    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [a show];    
    NSLog(@"Fail");
}

-(void)registerSuccess{
    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You were successfully registered. You can log in to your acount now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [a show];
    [self showLoginScreen:nil];
}

-(void)registerFailed:(NSString *)message{
    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [a show];    
    
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//Hiding the keyboard
-(void) hideKeyboard{
    for(UITextField * t in textFields)
    {
        [t resignFirstResponder];
    }
}


#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    manager = [Manager sharedInstance];
    manager.loginDelegate =self;
    manager.registerDelegate=self;
    //setting up text array with text fields
    textFields = [NSArray arrayWithObjects:emailLoginTextField,passwordLoginTextField,emailTextField,passwordTextField,confirmPasswordTextField,displayNameTextField, nil];
    for(UITextField * t in textFields)
    {
        t.delegate=self;
    }
    [registrationView removeFromSuperview];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setDisplayNameTextField:nil];
    [self setEmailLoginTextField:nil];
    [self setPasswordLoginTextField:nil];
    [self setRegistrationView:nil];
    [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

- (IBAction)registerUser:(id)sender {
    
    //Validating Data:
    int l1= emailTextField.text.length;
    int l2= passwordTextField.text.length;
    int l3= confirmPasswordTextField.text.length;
    int l4= displayNameTextField.text.length;
    
    //Check if all fields are filled
    if(l1>0&&l2>0&&l3>0&&l4>0)
    {
        //Check if the first field is an email:
        if([self NSStringIsValidEmail: emailTextField.text])
        {
            //Checking Passwords
            if([passwordTextField.text isEqualToString:confirmPasswordTextField.text])
            {
                [manager registerWithName:displayNameTextField.text andEmail:emailTextField.text andPassword:passwordTextField.text];
                [self hideKeyboard];
            }
            else{
                UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your passwords don't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
        }
        else{
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to provide a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
    }   
    else{
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to fill all fields to register a new user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
}


//Validating Email:
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)loginUser:(id)sender {
  
    NSLog(@"Trying to log in user....");
    
    
    //Validate fields
    int l1 = emailLoginTextField.text.length;
    int l2 = passwordLoginTextField.text.length;
    //Checking if fields are filled
    if(l1>0&&l2>0)
    {
        //Checking for valid email
        //Check if the first field is an email:
        if([self NSStringIsValidEmail: emailLoginTextField.text])
        {
            //trying to log in:
            [manager loginWithLogin:emailLoginTextField.text andPassword:passwordLoginTextField.text]; 
            [self hideKeyboard];
        }
        else{
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to provide a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }
    }
    else{
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to fill all fields to log in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
        
    }
}

- (IBAction)showRegistrationScreen:(id)sender {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
    [self.view addSubview: registrationView];
    [UIView commitAnimations];
    [self hideKeyboard];    
}

- (IBAction)showLoginScreen:(id)sender {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
    [registrationView removeFromSuperview];
    [UIView commitAnimations];
    [self hideKeyboard];
}

@end
