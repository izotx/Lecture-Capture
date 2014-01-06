//
//  MailHelper.m
//  MathFractions
//
//  Created by Janusz Chudzynski on 11/25/13.
//  Copyright (c) 2013 UWF. All rights reserved.
//

#import "MailHelper.h"


@interface MailHelper()<MFMailComposeViewControllerDelegate>
@property (nonatomic,strong)UIViewController * vc;
@end
@implementation MailHelper 

- (void)contactSupport:(id)sender;{
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
        [sender presentViewController:mailer animated:YES completion:nil];
        
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

- (void)shareURL:(id)sender {
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
        [sender presentViewController:mailer animated:YES completion:nil];
        
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


-(void)sendEmailFromVC:(id)vc{
if([MFMailComposeViewController canSendMail])
{
    _vc= vc;
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    [mailer setToRecipients:@[@"jchudzynski@uwf.edu",@"gnguyen@uwf.edu"]];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Contact Fractio Support"];

    NSMutableString *body = [NSMutableString string];
    // add HTML before the link here with line breaks (\n)
    [body appendString:@"Please describe your concerns or questions below:<br>\n"];
    [body appendString:@"Our team will do their best to help you.<br>\n"];
    
    [body appendString:@"Thanks much! <br> \n"];
    [mailer setMessageBody:body isHTML:YES];
    
    // only for iPad
    mailer.modalPresentationStyle = UIModalPresentationPageSheet;
    [vc presentViewController:mailer animated:YES completion:nil];
    
}
else
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:@"We can't send email from this device."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
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
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
