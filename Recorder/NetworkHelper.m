//
//  NetworkHelper.m
//  Lecture Capture
//
//  Created by DJMobile INC on 5/22/13.
//
//

#import "NetworkHelper.h"
#import "AFNetworking.h"
#import "Manager.h"
#import "Lecture.h"


#define MaxSize 100
@interface NetworkHelper(){
    BlockTest  successBlock;
    BlockTest  errorBlock;
    AFHTTPClient * afClient;
}

@end

@implementation NetworkHelper


-(void)uploadVideo:(Lecture *)lecture andManager:(Manager *)manager;{

    
#pragma mark warning - revisit it
    afClient = [AFHTTPClient clientWithBaseURL:[[Manager sharedInstance]url]];
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:@[lecture.name, manager.loginName,manager.loginPassword] forKeys:@[@"Title",@"email",@"password"]];
    NSLog(@"Now what? 1 ");
   NSURLRequest * request = [afClient multipartFormRequestWithMethod:@"POST" path:nil parameters:dict constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        NSData * data = [NSData dataWithContentsOfFile:lecture.filepath];
        if(!data){
            NSLog(@" File not found %@",lecture.filepath);
        }
        [formData appendPartWithFileData:data name:@"userfile" fileName:lecture.filepath mimeType:@"video/quicktime"];
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
            NSLog(@"%@ and %@" ,ext,acext);

            if(![ext isEqualToString:acext])
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Error. Your recording couldn't be uploaded at this time. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            else{
                lecture.url = newStr;
               
                
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
    
    
}



-(void)saveToDatabase{
    
}


-(void)setCompletionBlocks:(BlockTest) _successBlock andError:
(BlockTest) _errorBlock{
    successBlock = _successBlock;
    errorBlock = _errorBlock;
    
}


@end
