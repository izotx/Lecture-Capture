//
//  RecordingOperationsViewController.m
//  Lecture Capture
//
//  Created by sadmin on 1/2/14.
//
//

#import "RecordingOperationsViewController.h"
#import "Manager.h"
#import "Lecture.h"
#import "NetworkHelper.h"
#import "IOHelper.h"


@interface RecordingOperationsViewController ()
- (IBAction)deleteRecording:(id)sender;
- (IBAction)playRecording:(id)sender;
- (IBAction)editRecording:(id)sender;
- (IBAction)uploadRecording:(id)sender;
- (IBAction)saveToLibrary:(id)sender;



@end

@implementation RecordingOperationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        /*
         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
         pasteboard.string = self.movie_url_label.text;
         UIAlertView * a =[[UIAlertView alloc]initWithTitle:@"Lecture Capture" message:@"The url of your recording was copied to a clipboard." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
         [a show];

         */
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteRecording:(id)sender {
}

- (IBAction)playRecording:(id)sender {
}

- (IBAction)editRecording:(id)sender {
}

- (IBAction)uploadRecording:(id)sender {
    //check if user is logged in
    
}

- (IBAction)saveToLibrary:(id)sender {
    [_iohelper saveToLibraryFileAtPath:videoPath];

    
}

-(void)postMovie:(NSString * )filePath{
    Manager * manager = [Manager sharedInstance];
    NetworkHelper * networkHelper = [[NetworkHelper alloc]init];
    if(manager.userId){
        if(filePath.length==0)
        {
        }
        else{
            NSLog(@"Video Size %f",[self.lecture.size floatValue]);
            if([self.lecture.size floatValue] > 100 )
            {
                UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Unfortunately, the selected recording is too large to uplaod it to the server. Currently the file size limit it 100 MB." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [a show];
            }
            else{
                // upload video here
                [networkHelper setCompletionBlocks:^(){
                    
                    
                } andError:^(
                 
                 ){
                     
                 }];

                [networkHelper uploadVideo:currentVideo andManager:manager andVideoPath:filePath];
            }
        }
    }
    else{
        uploadLogin = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You need to log in in order to upload recordings to the server. Would you like to do it now?" delegate:self cancelButtonTitle:@"Yes, please!" otherButtonTitles:@"No, thanks", nil];
        [uploadLogin show];
    }
}



@end
