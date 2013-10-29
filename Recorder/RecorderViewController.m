//
//  RecorderViewController.m
//  Recorder
//
//  Created by Janusz Chudzynski on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
/*
    P L A N

    1. When Start - create a part + randomName
    2. Store it in movieNameArray
    3. Pause -> save a part
    4. Create a new part
    5 End - Combine all movies sounds
 
 
*/

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

#import "RecorderViewController.h"
#import "AppDelegate.h"

#import "Utilities.h"
#import "UIImage+Resize.h"
#import "VideoPreview.h"
#import "IOHelper.h"


#define FRAME_RATE 10

@interface UIImage (Extras)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end;
@implementation UIImage (Extras)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end

@interface NonRotatingUIImagePickerController : UIImagePickerController

@end

@implementation NonRotatingUIImagePickerController

- (BOOL)shouldAutorotate
{
    return NO;
}
@end


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

    UIImageView * preview;

    BOOL interrupted;
    BOOL recordingStarted;
    BOOL paused;
    BOOL ready;
    
    int frameCounter;
    __weak IBOutlet UILabel *durationLabel;
    NSMutableArray * scrollViewScreenshots;
    NSMutableArray * moviePieces;
    NSMutableArray * audioPieces;
    
    UIView * recordingStartView;
    
    AudioRecorder * ar;
    ILColorPickerDualExampleController * cp;
    VideoPreview * vp;
    IOHelper * ioHelper;
    
    
}
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;

- (IBAction)eraseRecording:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)makeScreenShot:(id)sender;
-(NSString* ) timeConverter:(int)durationInSeconds;
-(IBAction)finishRecording:(id)sender;
- (IBAction)addVideoPreview:(id)sender;
    

@property(nonatomic, assign) BOOL bannerIsVisible;

@end

@implementation RecorderViewController
@synthesize movie_title;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize bannerView;
@synthesize bannerIsVisible;
@synthesize eraseMode;
@synthesize toolbar;
@synthesize colorBarButton;
#pragma mark helper
-(NSString* ) timeConverter:(int)durationInSeconds{
    Utilities * u = [[Utilities alloc]init];
    return [u timeConverter:durationInSeconds];
}


#pragma mark delegate
- (void) recordingFinished:(BOOL)success{
       ready = YES;
}

-(void)recordingInterrupted{

    interrupted = YES;
    [self pauseRecording:nil];

}

- (void) recordingStartedNotification{
    DebugLog(@"Recording Started ");
    recordingScreenView.recording = YES;
    
    if(ar.recorderFilePath!=nil && recordingScreenView.outputPath!=nil){
        NSString * lastObject;
        lastObject = [audioPieces lastObject];
        
        if([ar.recorderFilePath isEqualToString:lastObject])
        {
          
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordingStartedNotification) userInfo:nil repeats:NO];
        }
        else{
            [audioPieces addObject:ar.recorderFilePath];
        }
        
         lastObject = [moviePieces lastObject];
        if([recordingScreenView.outputPath isEqualToString:lastObject])
        {
          //  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordingStartedNotification) userInfo:nil repeats:NO];
        }
        else{
             [moviePieces addObject:recordingScreenView.outputPath];
        }        
        
        if(![durationTimer isValid]){
            durationTimer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(durationTimerCallback) userInfo:nil repeats:YES];
        
            NSRunLoop *runner = [NSRunLoop currentRunLoop];
            [runner addTimer:durationTimer forMode: NSDefaultRunLoopMode];
            [self.informationLabel removeFromSuperview];
        }
    // Remove recording screen
        [recordingStartView removeFromSuperview];
        [activityIndicator stopAnimating];
    
    }
    else{
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordingStartedNotification) userInfo:nil repeats:NO];
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
    recordingStarted = NO;
    
    [scrollView setContentSize:scrollView.frame.size];
    ar = [[AudioRecorder alloc]init];
    bannerIsVisible = NO;
    vp = [[VideoPreview alloc]initWithFrame:CGRectZero];
    cp=[[ILColorPickerDualExampleController alloc]initWithNibName:@"ILColorPickerDualExampleController" bundle:nil];
        cp.delegate = self;

    moviePieces = [[NSMutableArray alloc]initWithCapacity:0];
    audioPieces=  [[NSMutableArray alloc]initWithCapacity:0];
    ready = YES;
    paused = NO;
}

- (void)viewDidUnload
{
    recordingScreenView = nil;
    durationLabel = nil;
    recordingScreenView = nil;
    scrollView = nil;
     activityIndicator = nil;
    [self setBannerView:nil];
    backgroundView = nil;
    [self setToolbar:nil];
    [self setColorBarButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidAppear:(BOOL)animated{
    [self manageOrientationChanges];
 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //We need to rotate the preview:
    
    return (interfaceOrientation==UIInterfaceOrientationLandscapeRight || interfaceOrientation==UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger) supportedInterfaceOrientations
{
    //Because your app is only landscape, your view controller for the view in your
    // popover needs to support only landscape
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self manageOrientationChanges];
}


-(void)manageOrientationChanges{
      UIDeviceOrientation orientation =[[UIDevice currentDevice]orientation];
        switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            {
                if(recordingScreenView.csm.front==NO){
                  recordingScreenView.rotatePreview = NO;
                }
                else
                {
                   recordingScreenView.rotatePreview = YES; 
                }
               
                break;}
        case UIDeviceOrientationLandscapeRight:
            {
                if(recordingScreenView.csm.front==NO){
                    recordingScreenView.rotatePreview = YES;
                }
                else{
                    recordingScreenView.rotatePreview = NO;
                }
                
                
                 break;
            }
            default:
            break;
    }
}


#warning HERE User Tapped on the Finish Button
-(IBAction)finishRecording:(id)sender
{
    if(ar.recorderFilePath!=nil && recordingScreenView.outputPath!=nil){
    UIView  * v = [[UIView alloc]initWithFrame:self.view.bounds];
    v.backgroundColor = [UIColor grayColor];
    [self.view addSubview:v];
    [v addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    if([durationTimer isValid]){
        [durationTimer invalidate];
         durationTimer =NULL;
    }
    [recordingScreenView performSelector:@selector(stopRecording)];
    [ar performSelector:@selector(stopRecording)];

    if(ready==NO){
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(finishRecording:) userInfo:nil repeats:NO];

    }
    else{

        if(!ioHelper){
            ioHelper  = [[IOHelper alloc]init];
            
        }
        NSString * path = [ioHelper getRandomFilePath];
        [ioHelper putTogetherVideo:moviePieces andAudioPieces:audioPieces andCompletionBlock:^(BOOL success,CMTime duration) {
                NSLog(@"Method returned.");
            NSString * message;
            if(success){
                [self saveData:duration ofPath:path];
                message = @"Movie successfully saved.";
            }
            else{
                message = @"Movie wasn't successfully saved.";                
            }
             [self performSelectorOnMainThread:@selector(dismissMe:) withObject:message waitUntilDone:NO];
            } saveAtPath:path];
      }
    }
    else{
        [self dismissMe:nil];
    }
}

-(IBAction)startRecording:(id)sender
{
    if(paused==YES||recordingStarted==NO){
     if(!ready)
      {
        self.informationLabel.text = @"Recorder is not ready yet.Please try again.";
          NSLog(@"Not ready yet");
      }
     else
        {
           recordingStartView = [[UIView alloc]initWithFrame:self.view.bounds];
           recordingStartView.backgroundColor = [UIColor darkGrayColor];
            
           UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(281,10,553,40)];

           [label setFont:[UIFont systemFontOfSize:20]];
           [label setText:@"Setting up your recording."];
           label.backgroundColor =  [UIColor darkGrayColor];
           label.textColor = [UIColor lightGrayColor];
           label.lineBreakMode = NSLineBreakByWordWrapping;
           label.numberOfLines = 2;
 
            [recordingStartView addSubview:label];

            
            
           [self.view addSubview: recordingStartView];
           [recordingStartView addSubview:activityIndicator];
           [activityIndicator startAnimating];
            
        [recordingScreenView performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
        [ar performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];            
        recordingStarted = YES;
        paused = NO;
        ready = NO;
            
        }
     }
}

-(IBAction)pauseRecording:(id)sender
{
    if(recordingStarted){
    if(!paused){
        [recordingScreenView performSelector:@selector(stopRecording)];
        [ar performSelector:@selector(stopRecording)];
        [self.view addSubview:self.informationLabel];
        self.informationLabel.text = @"Recording is Paused. Press on the Record button to start recording again or Finish button to stop.";
        paused = YES;
        if([durationTimer isValid]){
            [durationTimer invalidate];
            durationLabel.text = @"Recording Paused";
        }
        [self dismiss];//remmoving preview
    }
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
    [recordingScreenView.paintView removeBackgroundPhoto];
    [recordingScreenView.paintView eraseContext];
}

- (IBAction)makeScreenShot:(id)sender {

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
  
    testImageView.image=recordingScreenView.currentScreen;
    [scrollViewScreenshots addObject:s];
}



//Save to Core Data
-(BOOL)saveData:(CMTime)d ofPath:(NSString * )pathToSave{
    if(!self.managedObjectContext)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext=appDelegate.managedObjectContext;
    }
    int durationInSeconds = CMTimeGetSeconds(d);
    NSString* time =    [self timeConverter:durationInSeconds];
    //Calculating size
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:pathToSave error:nil];
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
        return YES;
    }
    else{
        NSLog(@"Error %@",[error debugDescription]);
        return NO;
    }
}

-(void)dismissMe:(NSString *) message{
    [activityIndicator stopAnimating];
    if(message){
    UIAlertView * alert= [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    }
    if(interrupted){
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
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
            
- (IBAction)changeBrushSize:(id)sender {
    float val = [(UISlider *)sender value];
    [recordingScreenView.paintView setSizeOfBrush:val];
}

#pragma mark COLOR 

- (IBAction)pickColorFor:(id)sender {
    int tag = [sender tag];
    cp.operationType= tag;

    if(!colorPopover){
        colorPopover = [[UIPopoverController alloc]initWithContentViewController:cp];
        [colorPopover setPopoverContentSize:CGSizeMake(320, 412)]; 
    }
    
    if(cp.operationType ==10)
    {
        [colorPopover presentPopoverFromBarButtonItem:colorBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
    else{
       [colorPopover presentPopoverFromBarButtonItem:colorBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
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
    
    UIImagePickerController *cameraUI = [[NonRotatingUIImagePickerController alloc] init];
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
        [cameraPopover presentPopoverFromBarButtonItem:cameraBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
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
    UIImagePickerController *cameraUI = [[NonRotatingUIImagePickerController alloc] init];
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
       [cameraPopover presentPopoverFromBarButtonItem:cameraBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
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
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        
        if (editedImage) {
            imageToSave = editedImage;
            
            
        } else {
            imageToSave = originalImage;
        }
        
    }
    [self performSelectorInBackground:@selector(useImage:) withObject:imageToSave];  

    [picker dismissViewControllerAnimated:YES completion:nil];
    [cameraPopover dismissPopoverAnimated:YES];
}



-(void)useImage:(UIImage *)image
    {
        CGSize size = CGSizeMake(recordingScreenView.paintView.frame.size.width, recordingScreenView.paintView.frame.size.height);
        UIImage * im = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:size interpolationQuality:kCGInterpolationLow];
        
        [self performSelectorOnMainThread:@selector(updateViewWithImage:) withObject:im waitUntilDone:NO];
    }

-(void) updateViewWithImage:(UIImage *) im{
    [recordingScreenView.paintView setBackgroundPhotoImage:im];
}
     

- (IBAction)changeBackground:(id)sender {
    photoAction=[[UIActionSheet alloc]initWithTitle:@"Set Background" delegate:self cancelButtonTitle:nil   destructiveButtonTitle:@"Cancel"  otherButtonTitles:@"New Photo", @"Photo Library", @"Background Color",@"Line Paper",@"Graph Paper", @"Clear Background", nil];
    [photoAction showInView:self.view];
}

- (IBAction)eraserOnOff:(id)sender {
  
    eraseMode = !recordingScreenView.paintView.eraseMode;
    recordingScreenView.paintView.eraseMode = eraseMode;
//Very Error Prone. Change the Bar Button Item based on it's index.

    //Record Flex Erase
    //
    
    NSMutableArray * buttons =[[NSMutableArray alloc]initWithArray:toolbar.items ];
   
    UIBarButtonItem * stopErasing =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(eraserOnOff:)];
     UIBarButtonItem * erase =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(eraserOnOff:)];
   
    int index = buttons.count -3;
    [buttons removeObjectAtIndex:index];
    if(eraseMode){
       [buttons insertObject:stopErasing atIndex:index];
        
    }
    else{
        [buttons insertObject:erase atIndex:index];
    }
    [toolbar setItems:buttons animated:YES];
}

- (IBAction)redoAction:(id)sender {
   // [recordingScreenView.paintView redo];
    
}

- (IBAction)undoAction:(id)sender {
        [recordingScreenView.paintView undo];
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
        else if(buttonIndex==4)
        {
            [recordingScreenView.paintView setBackgroundPhotoImage:[UIImage imageNamed:@"linepaper"]];
        }
        else if(buttonIndex==5)
        {
            [recordingScreenView.paintView setBackgroundPhotoImage:[UIImage imageNamed:@"graphpaper"]];        }
        else if(buttonIndex==6) // Remove Photo
        {
            [recordingScreenView.paintView removeBackgroundPhoto];
        }
    }
}



- (void)didReceiveMemoryWarning{
  
    NSLog(@"Memory Managements");
    [super didReceiveMemoryWarning];
    
}

#pragma mark preview
-(void)dismiss{
    NSLog(@" Dismiss Me Recorder ");
    [vp removeFromSuperview];
    //stop session and etc.
    [recordingScreenView removeVideoPreview];
    
}
-(void)switchCamera
{
    [recordingScreenView switchCamera];
}

/* Resizing the Screen */
-(void)resizeMe{
    vp.fullScreen = !vp.fullScreen;
    [vp adjustToFullScreen:vp.fullScreen];
    recordingScreenView.fullScreen =vp.fullScreen;
    recordingScreenView.videoPreviewFrame =  vp.previewImageView.frame;
}

- (IBAction)addVideoPreview:(id)sender {
    
    if(! [recordingScreenView.csm.captureSession isRunning]){
        vp.backgroundColor = [UIColor grayColor];
        vp.target = self;
        vp.width = recordingScreenView.frame.size.width;
        vp.height = recordingScreenView.frame.size.height;
        [vp adjustToFullScreen:NO];
        [recordingScreenView addVideoPreview];
        recordingScreenView.fullScreen =NO;
        [self.view addSubview:vp];
      }
}

-(void)previewUpdated:(UIImage *)img{
    [self performSelectorOnMainThread:@selector(updatePreviewWithImage:) withObject:img waitUntilDone:NO];

}


-(void)updatePreviewWithImage:(UIImage *)img{
    recordingScreenView.videoPreviewFrame =  vp.previewImageView.frame;
    vp.previewImageView.image = img;

   // recordingScreenView.paintView.backgroundImage  =img;
    [self manageOrientationChanges];
}




@end
