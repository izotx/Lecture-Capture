//
//  NetworkHelper.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 5/22/13.
//
//

#import "NetworkHelper.h"

#define MaxSize 100
@interface NetworkHelper(){
    BlockTest  successBlock;
    BlockTest  errorBlock;
}

@end

@implementation NetworkHelper


-(void)uploadVideo:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath {
    NSURL * url = [[NSURL alloc]initWithString:@"http://djmobilesoftware.com/screencapture/videoUpload.php"];

    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:currentVideo.title forKey:@"Title"];
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
            
        }];
        // END OF COMPLETION BLACK
        successBlock();
        [request setFailedBlock:^{
            NSLog(@"Failed, %@",[request error]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
        }];
        
        request.delegate=self;
        [request setTimeOutSeconds:-1];
        [request startAsynchronous];
    
        
    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}



-(void)saveToDatabase{
    
}


-(void)setCompletionBlocks:(BlockTest) _successBlock andError:
(BlockTest) _errorBlock{
    successBlock = _successBlock;
    errorBlock = _errorBlock;
    
}


@end
