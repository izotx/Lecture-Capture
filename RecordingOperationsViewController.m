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
#import "LectureAPI.h"
#import "WebVideoView.h"
#import "RecorderViewController.h"


@interface RecordingOperationsViewController ()
- (IBAction)deleteRecording:(id)sender;
- (IBAction)playRecording:(id)sender;
- (IBAction)editRecording:(id)sender;
- (IBAction)uploadRecording:(id)sender;
- (IBAction)saveToLibrary:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *container;
@property(strong,nonatomic) WebVideoView * webview;
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
    _webview = [[WebVideoView alloc]initWithFrame:self.container.bounds];
    [_container addSubview:_webview];
    if(self.lecture.filepath){
        [_webview loadVideoWithURL:[NSURL fileURLWithPath:self.lecture.filepath]];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteRecording:(id)sender {
    [LectureAPI removeLecture:self.lecture];
}
//        if(l.slides.count>0){
//            NSSortDescriptor * ns = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
//
//            Slide * slide = [[[l.slides allObjects]sortedArrayUsingDescriptors:@[ns]]objectAtIndex:0];
//
//            NSData * data = slide.video;
//            if(data){
//                NSString * _videoPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [IOHelper  getRandomFilePath]];
//                [data writeToFile:_videoPath atomically:YES];
//                NSURL* outputURL = [NSURL fileURLWithPath:_videoPath];
//
//            }
//}


- (IBAction)playRecording:(id)sender {
    

}

- (IBAction)editRecording:(id)sender {
    UINavigationController * nav = super.navigationController;
    RecorderViewController * r = [self.storyboard instantiateViewControllerWithIdentifier:@"RecorderViewController"];
    r.lecture = self.lecture;
    [nav pushViewController:r animated:YES];
}

- (IBAction)uploadRecording:(id)sender {
    //check if user is logged in
    if([[Manager sharedInstance]userId]){
        [LectureAPI uploadLecture:self.lecture];
    }
    else{
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Log In to upload the recording." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];

    }
    
    /*
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
     */
    
}

- (IBAction)saveToLibrary:(id)sender {
    [LectureAPI saveLecturetoLibrary:self.lecture];
}





@end
