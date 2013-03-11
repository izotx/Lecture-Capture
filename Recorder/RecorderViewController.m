//
//  RecorderViewController.m
//  Recorder
//
//  Created by Janusz Chudzynski on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecorderViewController.h"
#import "AppDelegate.h"
#import "UIImageAddition.h"
#import "Utilities.h"
#import "UIImage+Resize.h"

#define FRAME_RATE 10
    
@interface RecorderViewController ()
{
    CMTime frameDuration;
    CMTime nextPresentationTimeStamp;
    NSString *moviepath;
    
    NSMutableArray * imagesNames;
    NSMutableArray * imageNamesCopy;
    
    NSMutableArray * imageFrames;
    NSString *documentsDirectory;
    
    NSTimer * recordFramesTimer;
    NSTimer * durationTimer;
    
  //  PaintView * paintView;
    AudioRecorder * ar;
    BOOL interrupted;
    int frameCounter;
    __weak IBOutlet UILabel *durationLabel;
    NSMutableArray * scrollViewScreenshots;
    ILColorPickerDualExampleController * cp;
    
}

- (IBAction)eraseRecording:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)makeScreenShot:(id)sender;
-(NSString* ) timeConverter:(int)durationInSeconds;
-(void)putTogether;
- (IBAction)startOrPauseRecording:(id)sender;

@property(nonatomic, assign) BOOL bannerIsVisible;

@end

@implementation RecorderViewController
@synthesize movie_title;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize bannerView;
@synthesize bannerIsVisible;

#pragma mark helper
-(NSString* ) timeConverter:(int)durationInSeconds{
    Utilities * u = [[Utilities alloc]init];
    return [u timeConverter:durationInSeconds];
}


#pragma mark delegate
- (void) recordingFinished:(NSString*)outputPathOrNil{
    if(outputPathOrNil)
    {
          [self putTogether];
    }
}

-(void)recordingInterrupted{
    DebugLog(@"Recording Interreptuded ");
    [recordingScreenView performSelector:@selector(stopRecording)];
    [ar performSelector:@selector(stopRecording)];
    interrupted = YES;
    if([durationTimer isValid])
    {
        [durationTimer invalidate];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    frameCounter =0;
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    scrollViewScreenshots =[[NSMutableArray alloc]initWithCapacity:0];
    
    recordingScreenView.delegate=self;
    
    [scrollView setContentSize:scrollView.frame.size];
    ar = [[AudioRecorder alloc]init];
    [self startOrPauseRecording:nil];  

    bannerIsVisible = NO;
    
    cp=[[ILColorPickerDualExampleController alloc]initWithNibName:@"ILColorPickerDualExampleController" bundle:nil];
        cp.delegate = self;    
}

- (void)viewDidUnload
{
    recordingScreenView = nil;
    durationLabel = nil;
    recordingScreenView = nil;
    scrollView = nil;
    stopOrRecordButton = nil;
     activityIndicator = nil;
    [self setBannerView:nil];
    backgroundView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation==UIInterfaceOrientationLandscapeRight || interfaceOrientation==UIInterfaceOrientationLandscapeLeft);
	
}


- (IBAction)startOrPauseRecording:(id)sender {
    if([[stopOrRecordButton titleForState:UIControlStateNormal]isEqualToString:@"Record"]||sender==nil)
    {
        [stopOrRecordButton setTitle:@"Done" forState:UIControlStateNormal];
           
       [recordingScreenView performSelector:@selector(startRecording) withObject:nil afterDelay:1.0];
       [ar performSelector:@selector(startRecording) withObject:nil afterDelay:1.0];
        durationTimer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(durationTimerCallback) userInfo:nil repeats:YES];

        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:durationTimer forMode: NSDefaultRunLoopMode];
    }    
    else{
        [stopOrRecordButton setTitle:@"Record" forState:UIControlStateNormal]; 
        if([durationTimer isValid]){
            [durationTimer invalidate];
            durationTimer =NULL;
        }
        [recordingScreenView performSelector:@selector(stopRecording)];
        [ar performSelector:@selector(stopRecording)];
        //Adding View 
        UIView  * v = [[UIView alloc]initWithFrame:self.view.bounds];
        v.backgroundColor = [UIColor grayColor];
        [self.view addSubview:v];
        [v addSubview:activityIndicator];
        [activityIndicator startAnimating]; 
    }
    
    
    
}

-(void) durationTimerCallback{
    frameCounter++;
   
    NSString * time =  [self timeConverter:frameCounter];
    
    durationLabel.text=[NSString stringWithFormat:@"Duration: %@",time];
}



- (IBAction)eraseRecording:(id)sender {
        [imageFrames removeAllObjects];
        frameCounter =0;
        durationLabel.text=[NSString stringWithFormat:@"Duration: %d",0];
}

- (IBAction)clearBoard:(id)sender {
    [recordingScreenView.paintView eraseContext];
    
}

- (IBAction)makeScreenShot:(id)sender {

//Little Calculations
    int count =  scrollViewScreenshots.count;

    float lastx;
    float lastWidth;
    float totalWidth=0;
    for( int i=0; i<count; i++)
    {
        
        ScreenView  *tempIMGView =[scrollViewScreenshots objectAtIndex:i];
        float tempWidth= tempIMGView.frame.size.width;
        totalWidth+=tempWidth;
        lastWidth= tempWidth;
        lastx = tempIMGView.frame.origin.x;
    }
    
    totalWidth=lastx +lastWidth + 5;

    //Calculate new width
    float scrollHeight = scrollView.frame.size.height-10;
    float screenHeight = recordingScreenView.frame.size.height;
    float screenWidth= recordingScreenView.frame.size.width;
    float newWidth = screenWidth *scrollHeight/screenHeight;
    
    CGRect newFrame = CGRectMake(totalWidth, 5, newWidth,scrollHeight);
    
    UIImage * image=recordingScreenView.paintView.image;
    UIImageView * imageView =[[UIImageView alloc]initWithImage:image];
    imageView.frame =CGRectMake(3, 3, newWidth-6, scrollHeight-6);
  
    ScreenView * s = [[ScreenView alloc]initWithFrame:newFrame];
    [s addSubview:imageView];
    s.image=image;
    s.delegate=self;
    s.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:s];
    
    totalWidth +=newWidth +25; 
    if(totalWidth > scrollView.contentSize.width)
    {
        scrollView.contentSize = CGSizeMake(totalWidth, scrollHeight);
    }
    if(recordingScreenView.currentScreen)
    {
        NSLog(@"It Exists");
    }
    else {
        NSLog(@"It doesn't exist");
    }
    testImageView.image=recordingScreenView.currentScreen;
    
    [scrollViewScreenshots addObject:s];
    
}




-(void)putTogether
{
  
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    NSString *audioPath = [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"caldate.caf"];
    
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    //AVURLAsset *audioasset = [AVURLAsset URLAssetWithURL:audioUrl options:nil];
    AVURLAsset *audioasset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    
    NSString * videoPath = [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"output.mp4"];
    
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *videoasset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString * pathToSave = [NSString stringWithFormat:@"%@_output.mov",caldate];
    
    moviepath =  [DOCUMENTS_FOLDER stringByAppendingPathComponent:pathToSave];
    
    NSURL *movieUrl = [NSURL fileURLWithPath:moviepath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:moviepath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:moviepath error:nil];
    }
    
    AVMutableCompositionTrack *compositionTrackB = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrackB = [[videoasset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    [compositionTrackB insertTimeRange:CMTimeRangeMake( kCMTimeZero, videoasset.duration)  ofTrack:clipVideoTrackB atTime:kCMTimeZero error:nil];
    
    CMTime d =    videoasset.duration;
       CMTimeValue val = videoasset.duration.value;
 
    
    
    
    AVMutableCompositionTrack *compositionTrackA = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipAudioTrackA = [[audioasset tracksWithMediaType:AVMediaTypeAudio] lastObject];
    [compositionTrackA insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset.duration)  ofTrack:clipAudioTrackA atTime:kCMTimeZero error:nil];
    

    AVAssetExportSession *exporter =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    //AVAssetExportSession *exporter =[AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetLowQuality];
    NSParameterAssert(exporter!=nil);
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    exporter.outputURL=movieUrl;
    exporter.shouldOptimizeForNetworkUse=YES;
CMTime start=CMTimeMake(0, 600);
CMTime duration=CMTimeMake(val, 600);
CMTimeRange range=CMTimeRangeMake(start, duration);
exporter.timeRange=range;

[exporter exportAsynchronouslyWithCompletionHandler:^{ 
    switch ([exporter status]) {
        case AVAssetExportSessionStatusFailed:{
            NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);
            NSString * message = @"Movie wasn't created. Try again later.";
            [self performSelectorOnMainThread:@selector(dismissMe:) withObject:message waitUntilDone:NO];
            break;}
        case AVAssetExportSessionStatusCancelled:{ NSLog(@"Export canceled");
            NSString * message1 = @"Movie wasn't created. Try again later.";
            [self performSelectorOnMainThread:@selector(dismissMe:) withObject:message1 waitUntilDone:NO];
            break;}
        case AVAssetExportSessionStatusCompleted: 
        {
            NSLog(@"MOV Video Successefully Exported!");
            //Save to core data
            
            
            
            if(!self.managedObjectContext)
            {
                NSLog(@"Managed Object COntext doesnt exist");
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                self.managedObjectContext=appDelegate.managedObjectContext;
                
            }
            int durationInSeconds = CMTimeGetSeconds(d);
            NSString* time =    [self timeConverter:durationInSeconds];
            //Calculating size 
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:moviepath error:nil];
            NSString *fileSize;
            if(fileAttributes != nil)
            {
             fileSize = [fileAttributes objectForKey:NSFileSize];
                float fileSizeMB = [fileSize intValue]/1024.0/1024.0;
                NSLog(@"File Size is: %@ %f",fileSize,fileSizeMB);
                fileSize=[NSString stringWithFormat:@"%.1f MB",fileSizeMB];
            }
            else{
            fileSize=@"";
            }
            
            
            Video * videoObject= [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
            videoObject.video_path= pathToSave;
            videoObject.title=self.movie_title;
            videoObject.duration =time;
            videoObject.video_size=fileSize;

            NSError * error=nil;
            [self.managedObjectContext save:&error];
            if(error==nil)
            {
                NSLog(@"Data Saved");
            }
            else{
                NSLog(@"Error %@",[error debugDescription]);
            }
             NSString * message = @"Processing the recording. It will appear in the list on your left soon.";
             [self performSelectorOnMainThread:@selector(dismissMe:) withObject:message waitUntilDone:NO];

            break;
        }

        default:
            break;
    } 
}];   
}




-(void)dismissMe:(NSString *) message{
    [activityIndicator stopAnimating];
     
    UIAlertView * alert= [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    if(interrupted){
        [self dismissModalViewControllerAnimated:NO];
    }
    else{
        [self dismissModalViewControllerAnimated:YES];
    }
}
#pragma  mark iAD
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, +banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;

    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}



#pragma mark screen shot delegate

- (void) screenshotTapTwice:(UIImage *)im{
    [recordingScreenView.paintView eraseContext];
    [recordingScreenView.paintView setBackgroundPhotoImage:im];
    
}
            


- (IBAction)cancelExporting:(id)sender {
}

- (IBAction)changeBrushSize:(id)sender {
    float val = [(UISlider *)sender value];
  
    [recordingScreenView.paintView setSizeOfBrush:val];
    
}

#pragma mark COLOR 

- (IBAction)pickColorFor:(id)sender {
    int tag = [sender tag];
    
    NSLog(@"Change tag to %d",tag);
    cp.operationType= tag;

    if(!colorPopover){
        colorPopover = [[UIPopoverController alloc]initWithContentViewController:cp];
        [colorPopover setPopoverContentSize:CGSizeMake(320, 412)]; 
    }
    
    if(cp.operationType ==10)
    {
        [colorPopover presentPopoverFromRect:cameraBarButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    else{
    [colorPopover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
  }


-(void) colorPicked: (UIColor *) color forView: (int) viewIndex;
{
    UIButton * but =( UIButton *) [self.view viewWithTag:viewIndex];
    [but setBackgroundColor:color];
    if(viewIndex==10)
    {
       [recordingScreenView.paintView setColorOfBackground:color];
    }
    else{
       [recordingScreenView.paintView setBrushStrokeColor:color];

    }
}

#pragma mark adding image
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    NSLog(@"Cancel ");
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark camera
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO))
    {   UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"We were not able to find a camera on this device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    if(!cameraPopover.isPopoverVisible){
            cameraPopover=[[UIPopoverController alloc]initWithContentViewController:cameraUI];
        [cameraPopover presentPopoverFromRect:cameraBarButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];    
        }
    return YES;
}

- (BOOL) startCameraControllerPickerViewController: (UIViewController*) controller
                                     usingDelegate: (id <UIImagePickerControllerDelegate,
                                                     UINavigationControllerDelegate>) delegate {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO )
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"We were not able to use photo album on this device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];   
        return NO;
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:
                          UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    if(!cameraPopover.isPopoverVisible){
        cameraPopover=[[UIPopoverController alloc]initWithContentViewController:cameraUI];
        [cameraPopover presentPopoverFromRect:cameraBarButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        
        
        }
      return YES;    
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    //  NSLog(@"Did Finish Picking");
    UIImage *originalImage, *editedImage;
    UIImage * imageToSave;
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
            
            
        } else {
            imageToSave = originalImage;
        }
        
    }
    NSLog(@"picker did finish");
    [self performSelectorInBackground:@selector(useImage:) withObject:imageToSave];  

    [picker dismissModalViewControllerAnimated:YES];
    [cameraPopover dismissPopoverAnimated:YES];
}



-(void)useImage:(UIImage *)image
    {
        CGSize size = CGSizeMake(recordingScreenView.paintView.frame.size.width, recordingScreenView.paintView.frame.size.height);
        UIImage * im = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:size interpolationQuality:kCGInterpolationHigh];
        
        [self performSelectorOnMainThread:@selector(updateViewWithImage:) withObject:im waitUntilDone:NO];
    }

-(void) updateViewWithImage:(UIImage *) im{
    [recordingScreenView.paintView setBackgroundPhotoImage:im];
}
     

- (IBAction)takePhoto:(id)sender {
    photoAction=[[UIActionSheet alloc]initWithTitle:@"Set Background" delegate:self cancelButtonTitle:nil   destructiveButtonTitle:@"Cancel"  otherButtonTitles:@"New Photo", @"Photo Library", @"Background Color",@"Remove Background Photo", nil];
    [photoAction showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    
    if([actionSheet isEqual:photoAction]){
        if(buttonIndex==1) // make photo
        {
            [self startCameraControllerFromViewController:self usingDelegate:self]; 
        }
        else if(buttonIndex==2)
        {
            [self startCameraControllerPickerViewController:self usingDelegate:self];
        }
        else if(buttonIndex==3)
        {
            UIButton * b =[[UIButton alloc]init];
            b.tag=10;
            [self pickColorFor:b];
        }
        else if(buttonIndex==4) // Remove Photo
        {
            [recordingScreenView.paintView removeBackgroundPhoto];
        }
    }
}

- (void)didReceiveMemoryWarning{
  
    NSLog(@"Memory Managements");
      [super didReceiveMemoryWarning];
    
}


@end
