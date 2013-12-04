//
//  RecorderViewController.m
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.
//



#import "RecorderViewController.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "UIImage+Resize.h"
#import "VideoPreview.h"
#import "IOHelper.h"
#import "LectureAPI.h"
#import "ImagePhotoPicker.h"
#import "TJLFetchedResultsSource.h"
#import "Lecture.h"
#import "WebVideoView.h"
#import "SlideAPI.h"
#import "Slide.h"
#import "Slide+Operations.h"
#import "AudioFile.h"
#import "VideoFile.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define FRAME_RATE 10

@interface RecorderViewController ()<TJLFetchedResultsSourceDelegate, UICollectionViewDelegate>
{
    CMTime frameDuration;
    CMTime nextPresentationTimeStamp;
    NSString *moviepath;
    
    NSMutableArray * imagesNames;
    NSString *documentsDirectory;
    NSTimer * durationTimer;
    UIImageView * preview;

    BOOL interrupted;
    BOOL ready;
    
    int frameCounter;
    __weak IBOutlet UILabel *durationLabel;
    NSMutableArray * scrollViewScreenshots;
    
    UIView * recordingStartView;
    
    AudioRecorder * ar;
    ILColorPickerDualExampleController * cp;
    VideoPreview * vp;
    IOHelper * ioHelper;
    
    
}
@property (strong,nonatomic) TJLFetchedResultsSource * datasource;
@property(strong, nonatomic) ImagePhotoPicker *photoPicker;
@property(strong,nonatomic) NSFetchedResultsController * fetchedController;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;
@property(strong,nonatomic) Slide * currentSlide;
@property(strong,nonatomic) SlideAPI * slideAPI;
@property(strong,nonatomic) WebVideoView * webVideoView;
@property(assign,nonatomic) BOOL recording;
@property(assign,nonatomic) BOOL stopped;
@property (strong,nonatomic) UIActionSheet *actionSheet;
@property (strong,nonatomic) NSOperationQueue* queue;
@property   BOOL paused;


- (IBAction)eraseRecording:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)makeScreenShot:(id)sender;
- (IBAction)finishRecording:(id)sender;
- (IBAction)addVideoPreview:(id)sender;
- (IBAction)addNewSlide:(id)sender;

@end

@implementation RecorderViewController




-(void)configureFetchedController{
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *frequest = [[NSFetchRequest alloc]init];
    [frequest setEntity: [NSEntityDescription entityForName: @"Slide" inManagedObjectContext:appDelegate.managedObjectContext ]];
    [frequest setPredicate: [NSPredicate predicateWithFormat: @"lecture == %@", self.lecture
                             ]];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    [frequest setSortDescriptors:@[sd]];
    
    _fetchedController = [[NSFetchedResultsController alloc]initWithFetchRequest:frequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:Nil cacheName:nil];
    _datasource  = [[TJLFetchedResultsSource alloc]initWithFetchedResultsController:_fetchedController  delegate:self];
    
    self.collectionView.dataSource = _datasource;
    self.collectionView.delegate = self;
    _slideAPI = [[SlideAPI alloc]init];
    
}

- (IBAction)dismiss:(id)sender {
    [self finishRecording:self];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark Lecture APIs
//adds new slide
- (IBAction)addNewSlide:(id)sender {
    //mark previous slide as unselected
    _currentSlide.selected = @0;
    
    Slide * slide = [LectureAPI addNewSlideToLecture:self.lecture];
    _currentSlide = slide;
    _currentSlide.selected = @1;
}

-(void)setLecture:(Lecture *)lecture{
    //loading current slides and etc.
    //probably we will need a collection view
  //  http://stackoverflow.com/questions/4199879/iphone-read-uiimage-frames-from-video-with-avfoundation
    _lecture = lecture;
    if(lecture.slides.count == 0){
        [self addNewSlide:nil];
    }
    else{
        
    }
}

-(void)loadSlide{
   //if slide contains video, display it
    
   //if slide contains audio display it as well
}

//Finish recording slide.
-(IBAction)finishRecording:(id)sender
{
    self.recording = NO;
   // [self addNewSlide:nil];
    
    if(!_queue){
        _queue = [[NSOperationQueue alloc]init];
    }
    //[_queue addOperationWithBlock:^{
       // if(ar.recorderFilePath!=nil && recordingScreenView.outputPath!=nil){
            if([durationTimer isValid]){
                [durationTimer invalidate];
                durationTimer =NULL;
            }
            if(!_stopped){
                [recordingScreenView performSelector:@selector(stopRecording)];
                [ar performSelector:@selector(stopRecording)];
                
                //
                recordingScreenView.outputPath = nil;
                ar.recorderFilePath =nil;

            }
                _stopped = YES;
            
            if(ready==NO){
                [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(finishRecording:) userInfo:nil repeats:NO];
                
            }
            else{
                
                if(!ioHelper){
                    ioHelper  = [[IOHelper alloc]init];
                    
                }
                 __block NSString * path = [ioHelper getRandomFilePath];
                NSArray * video = [self.currentSlide.videoFiles allObjects];
                NSArray * audio = [self.currentSlide.audioFiles allObjects];
                
                
                if(video.count >0 && audio.count >0 &&video.count == audio.count){
                    [ioHelper putTogetherVideo:video andAudioPieces:audio andCompletionBlock:^(BOOL success,CMTime duration, Slide *slide, NSString * path) {
                        
                        
                        NSString * message;
                        if(success){
                            
                            slide.duration = [NSNumber numberWithInt:CMTimeGetSeconds(duration)] ;
                            
                            NSError * error;
                            if(error){
                                NSLog(@"Error %@",error.debugDescription);
                            }
                            
                            [SlideAPI save];
                            [self.collectionView reloadData];
                            
                        }
                        else{
                            message = @"Movie wasn't successfully saved.";
                        }
                    } forSlide:self.currentSlide saveAtPath:path];
                }

                
            }
      //  }

}

-(IBAction)startRecording:(id)sender
{
    
    if(self.currentSlide.videoFiles.count >0){
    UIAlertView * alertV = [[UIAlertView alloc]initWithTitle:@"Lecture Capture" message:@"This slide contains the video, what would you like to do? " delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite it with a new recording", nil];
   
    [[alertV rac_buttonClickedSignal]subscribeNext:^(NSNumber * x) {
        NSLog(@"%@",x);
        if(x.integerValue==0){
            return;
        }
        //remove the video and audio objects from the current slide
        [self.currentSlide removeAudioFiles:self.currentSlide.audioFiles];
        [self.currentSlide removeVideoFiles:self.currentSlide.videoFiles];
        self.currentSlide.audio = nil;
        self.currentSlide.video = nil;
        self.currentSlide.duration =@0;
        self.currentSlide.size=@0;
        self.currentSlide.thumbnail = nil;
        [SlideAPI save];
  
    }];
     [alertV show];
    }
    
    
    if(_paused==YES||_recording==NO){
    {
        if(!ready)
      {
         self.informationLabel.text = @"Recorder is not ready yet.Please try again.";
          NSLog(@"Not ready yet");
      }
     else
        {
            [recordingScreenView performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
            [ar performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
            _recording = YES;
            _paused = NO;
            ready = NO;
            
           recordingStartView = [[UIView alloc]initWithFrame:self.view.bounds];
           recordingStartView.backgroundColor = [UIColor darkGrayColor];
            
           UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(281,10,553,40)];
           [label setFont:[UIFont systemFontOfSize:20]];
           [label setText:@""];
           
           label.backgroundColor =  [UIColor darkGrayColor];
           label.textColor = [UIColor lightGrayColor];
           label.lineBreakMode = NSLineBreakByWordWrapping;
           label.numberOfLines = 2;
           label.center = recordingStartView.center;
           label.contentMode = UIViewContentModeCenter;
           label.textAlignment = NSTextAlignmentCenter;
            
           [recordingStartView addSubview:label];
           [self.view addSubview: recordingStartView];
           [recordingStartView addSubview:activityIndicator];
           [activityIndicator startAnimating];
        }
     }
    }
}

-(IBAction)pauseRecording:(id)sender
{
    //if(recordingStarted){
    if(!_paused){
        [recordingScreenView performSelector:@selector(stopRecording)];
        [ar performSelector:@selector(stopRecording)];
        [self.view addSubview:self.informationLabel];

        _paused = YES;
        _recording = NO;
        if([durationTimer isValid]){
            [durationTimer invalidate];
        }
        }
 
}

-(void) durationTimerCallback{
    frameCounter++;
   
    NSString * time =  [Utilities timeConverter:frameCounter];
    
    durationLabel.text=[NSString stringWithFormat:@"Duration: %@",time];
}

- (IBAction)eraseRecording:(id)sender {
       // [imageFrames removeAllObjects];
        frameCounter =0;
        durationLabel.text=[NSString stringWithFormat:@"Duration: %d",0];
}

- (IBAction)clearBoard:(id)sender {
    [recordingScreenView.paintView removeBackgroundPhoto];
    [recordingScreenView.paintView eraseContext];
}

- (IBAction)makeScreenShot:(id)sender {

    int count =  scrollViewScreenshots.count;

    float lastx=0;
    float lastWidth=0;
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
    [LectureAPI saveLecture:self.lecture];
    
    /*
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
       // NSLog(@"File Size is: %@ %f",fileSize,fileSizeMB);
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
  */
    return YES;
    
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
        [colorPopover presentPopoverFromBarButtonItem:_colorBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
    else{
       [colorPopover presentPopoverFromBarButtonItem:_colorBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
  }


-(void) colorPicked: (UIColor *) color forView: (int) viewIndex
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
- (void)showImagePicker {
    [self.photoPicker showImagePickerForPhotoPicker:self withCompletionBlock:^(UIImage *img) {
      //  self.currentImage = img;
        if(img){
          UIImage *resizeImage = [img imageByScalingProportionallyToSize:recordingScreenView.frame.size];
          [self performSelectorInBackground:@selector(useImage:) withObject:resizeImage];
        }
    } andBarButtonItem:cameraBarButton];
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
    photoAction=[[UIActionSheet alloc]initWithTitle:@"Set Background" delegate:self cancelButtonTitle:nil   destructiveButtonTitle:@"Cancel"  otherButtonTitles:@"Photo Background", @"Background Color",@"Line Paper",@"Graph Paper", @"Clear Background", nil];
    [photoAction showInView:self.view];
}

- (IBAction)eraserOnOff:(id)sender {
  
    _eraseMode = !recordingScreenView.paintView.eraseMode;
    recordingScreenView.paintView.eraseMode = _eraseMode;
//Very Error Prone. Change the Bar Button Item based on it's index.

    //Record Flex Erase
    //
    
    NSMutableArray * buttons =[[NSMutableArray alloc]initWithArray:_toolbar.items ];
   
    UIBarButtonItem * stopErasing =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete_24.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(eraserOnOff:)];
     UIBarButtonItem * erase =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(eraserOnOff:)];
   
    int index = buttons.count -3;
    [buttons removeObjectAtIndex:index];
    if(_eraseMode){
       [buttons insertObject:stopErasing atIndex:index];
        
    }
    else{
        [buttons insertObject:erase atIndex:index];
    }
    [_toolbar setItems:buttons animated:YES];
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
          [self showImagePicker];
        
        }
        else if(buttonIndex==2)
        {
            UIButton * b =[[UIButton alloc]init];
            b.tag=10;
            [self pickColorFor:b];
        }
        else if(buttonIndex==3)
        {
            [recordingScreenView.paintView setBackgroundPhotoImage:[UIImage imageNamed:@"linepaper"]];
        }
        else if(buttonIndex==4)
        {
            [recordingScreenView.paintView setBackgroundPhotoImage:[UIImage imageNamed:@"graphpaper"]];        }
        else if(buttonIndex==5) // Remove Photo
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
-(void)dismissPreview{
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

#pragma mark delegate
- (void) recordingFinished:(BOOL)success{
    ready = YES;
}

-(void)recordingInterrupted{
    
    interrupted = YES;
    [self pauseRecording:nil];
    
}


- (void) recordingStartedNotification{

    recordingScreenView.recording = YES;
    
    if(ar.recorderFilePath!=nil && recordingScreenView.outputPath!=nil){
        AudioFile *  lastAudioObject = (AudioFile *) [self.currentSlide.audioFiles.allObjects  lastObject];

        if([ar.recorderFilePath isEqualToString:lastAudioObject.path])
        {
            
            [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordingStartedNotification) userInfo:nil repeats:NO];
        }
        else{
            
            [self.currentSlide addAudioPiece:ar.recorderFilePath];
        }
        
       VideoFile* lastVideoObject = [self.currentSlide.videoFiles.allObjects   lastObject];
        
        if([recordingScreenView.outputPath isEqualToString: lastVideoObject.path])
        {
            //  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordingStartedNotification) userInfo:nil repeats:NO];
        }
        else{
            [self.currentSlide addMoviePiece: recordingScreenView.outputPath];
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


#pragma mark - TJLFetchedResultsSourceDelegate & Collectiuon View

- (void)didInsertObjectAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView insertItemsAtIndexPaths:@[indexPath]];
    if(indexPath.row != 0) {
        [strongCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.currentSlide.selected = @0;
    //show slide on the screen
    self.currentSlide = [_fetchedController objectAtIndexPath:indexPath];
    self.currentSlide.selected = @1;
    
}



#pragma mark view management
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _stopped = NO;
    _paused = NO;
    
    [RACObserve(self, self.recording)subscribeNext:^(id x) {
        [self.view addSubview:self.informationLabel];
        self.informationLabel.backgroundColor = [UIColor redColor];
        self.informationLabel.textColor = [UIColor whiteColor];
        if (x) {
            self.informationLabel.text = @"";
            [self.informationLabel removeFromSuperview];
        }
        else{
            self.informationLabel.text = @"Recording is Paused. Press on the Record button to start recording again or Finish button to stop.";
            [self.view addSubview:self.informationLabel];
        }
        self.informationLabel.frame = CGRectMake(0,0,CGRectGetWidth(self.view.frame),30);
        
    }];
    
    [RACObserve(self, self.paused)subscribeNext:^(id x) {
        [self.view addSubview:self.informationLabel];
        self.informationLabel.backgroundColor = [UIColor redColor];
        self.informationLabel.textColor = [UIColor whiteColor];
        if (x) {
            self.informationLabel.text = @"";
            [self.informationLabel removeFromSuperview];
        }
        else{
            self.informationLabel.text = @"Recording is Paused. Press on the Record button to start recording again or Finish button to stop.";
            [self.view addSubview:self.informationLabel];
        }
        self.informationLabel.frame = CGRectMake(0,0,CGRectGetWidth(self.view.frame),30);
        
    }];

    
    
    
    
    _photoPicker = [[ImagePhotoPicker alloc]init];
    frameCounter =0;
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    scrollViewScreenshots =[[NSMutableArray alloc]initWithCapacity:0];
    recordingScreenView.delegate=self;
    _recording= NO;
    
    [scrollView setContentSize:scrollView.frame.size];
    ar = [[AudioRecorder alloc]init];
    
    vp = [[VideoPreview alloc]initWithFrame:CGRectZero];
    cp=[[ILColorPickerDualExampleController alloc]initWithNibName:@"ILColorPickerDualExampleController" bundle:nil];
    cp.delegate = self;
    
    _webVideoView = [[WebVideoView alloc]initWithFrame:recordingScreenView.frame];
    
    
    [self configureFetchedController];
    
    ready = YES;

    
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    recordingScreenView = nil;
    durationLabel = nil;
    recordingScreenView = nil;
    scrollView = nil;
    activityIndicator = nil;
    backgroundView = nil;
    [self setToolbar:nil];
    [self setColorBarButton:nil];
    [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
}

-(void)viewDidAppear:(BOOL)animated{
    [self manageOrientationChanges];
    
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


@end
