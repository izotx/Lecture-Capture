//
//  NetworkHelper.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 5/22/13.
//
//

#import "NetworkHelper.h"

#define MaxSize 100
@implementation NetworkHelper
-(void)uploadVideo:(NSString *) path title:(NSString *)title video:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath {

    NSLog(@"Video Size %f",[currentVideo.video_size floatValue]);
    if([currentVideo.video_size floatValue] > MaxSize )
    {
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Unfortunately, the selected recording is too large to uplaod it to the server. Currently the file size limit it 100 MB." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
    else{
        NSURL * url = [[NSURL alloc]initWithString:@"http://djmobilesoftware.com/screencapture/videoUpload.php"];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:title forKey:@"Title"];
        [request setPostValue:manager.loginName forKey:@"email"];
        [request setPostValue:manager.loginPassword forKey:@"password"];
        
        
        NSLog(@" Name and Password is: %@ %@ ",manager.loginName, manager.loginPassword);
        
        [request setFile:videoPath forKey:@"userfile"];
        [request setCompletionBlock:^{
            
            NSLog(@"Data %@", [request responseString]);
            NSString * response = [request responseString];
            //Check with regular expression
            NSString * ext = [[response pathExtension]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString * acext=@"mov";
            NSLog(@"%@ and %@" ,ext,acext);
            if(![ext isEqualToString:acext])
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            else{
                currentVideo.video_url=response;
               // self.movie_url_label.text=response;
                
                NSError * error=nil;
                [self.managedObjectContext save:&error];
                if(error==nil)
                {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = response;
                    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your recording was successfully uploaded to a server and the URL was copied to the clipboard. You can paste the URL in email or text message to share your recording with others." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [a show];
                   // copyURLButton.enabled=YES;
                }
                else{
                    NSLog(@"Error %@",[error debugDescription]);
                }
                
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            /*
            self.uploadingVideoLabel.hidden=YES;
            self.uploadingVideoActivityIndicator.hidden=YES;
            [self.uploadingVideoActivityIndicator stopAnimating];
             */
            
            
        }];
        // END OF COMPLETION BLACK
        
        [request setFailedBlock:^{
            NSLog(@"Failed, %@",[request error]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
           /*
            self.uploadingVideoLabel.hidden=YES;
            self.uploadingVideoActivityIndicator.hidden=YES;
            [self.uploadingVideoActivityIndicator stopAnimating];
            */
            
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }];
        
        request.delegate=self;
        [request setTimeOutSeconds:-1];
        [request startAsynchronous];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
      /*
        self.uploadingVideoLabel.hidden=NO;
        self.uploadingVideoActivityIndicator.hidden=NO;
        [self.uploadingVideoActivityIndicator startAnimating];
     */
    }
}


-(void)saveToDatabase{
    
}



@end
