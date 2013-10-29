//
//  NetworkHelper.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 5/22/13.
//
//

#import "NetworkHelper.h"
#import "AFNetworking.h"
#import "Manager.h"

#define MaxSize 100
@interface NetworkHelper(){
    BlockTest  successBlock;
    BlockTest  errorBlock;
    AFHTTPClient * afClient;
}

@end

@implementation NetworkHelper


-(void)uploadVideo:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath {

    
#pragma mark warning - revisit it
    afClient = [AFHTTPClient clientWithBaseURL:[[Manager sharedInstance]url]];
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:@[currentVideo.title,manager.loginName,manager.loginPassword] forKeys:@[@"Title",@"email",@"password"]];

   NSURLRequest * request = [afClient multipartFormRequestWithMethod:@"POST" path:nil parameters:dict constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        NSData * data = [NSData dataWithContentsOfFile:videoPath];
        if(!data){
            NSLog(@" File not found %@",videoPath);
        }
        [formData appendPartWithFileData:data name:@"userfile" fileName:videoPath mimeType:@"video/quicktime"];
       NSLog(@"Form Data Appended");
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   }];

     
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten,long long totalBytesExpectedToWrite){
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject){
            NSString* newStr = [[NSString alloc] initWithData:responseObject
                                                     encoding:NSUTF8StringEncoding];
            NSString * ext = [[newStr pathExtension]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString * acext=@"mov";
          

            if(![ext isEqualToString:acext])
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            else{
                currentVideo.video_url=newStr;
                
                NSError * error=nil;
                [self.managedObjectContext save:&error];
                if(error==nil)
                {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = newStr;
                    UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your recording was successfully uploaded to a server and the URL was copied to the clipboard. You can paste the URL in email or text message to share your recording with others." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [a show];
                    successBlock();
                }
                else{
                    NSLog(@"Error %@",[error debugDescription]);
                }
             
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
       
        }} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [a show];
            errorBlock();
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [operation start];
    

    
/*
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
 */
    
}



-(void)saveToDatabase{
    
}


-(void)setCompletionBlocks:(BlockTest) _successBlock andError:
(BlockTest) _errorBlock{
    successBlock = _successBlock;
    errorBlock = _errorBlock;
    
}


@end
