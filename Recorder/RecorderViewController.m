//
//  RecorderViewController.m
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.

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
#import <RACEXTScope.h>
#import "UICollectionView+Draggable.h"
#import "UICollectionViewDataSource_Draggable.h"

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
  
    int frameCounter;
    __weak IBOutlet UILabel *durationLabel;
    NSMutableArray * scrollViewScreenshots;
    
    ILColorPickerDualExampleController * cp;
    VideoPreview * vp;
    IOHelper * ioHelper;
}


@property (strong, nonatomic) IBOutlet UIView *sideControls;
@property (strong,nonatomic) TJLFetchedResultsSource * datasource;
@property(strong, nonatomic) ImagePhotoPicker *photoPicker;
@property(strong,nonatomic) Slide * currentSlide;
@property(strong,nonatomic) SlideAPI * slideAPI;
@property(strong,nonatomic) WebVideoView * webVideoView;
@property(strong,nonatomic) AudioRecorder * ar;
@property (strong, nonatomic) UIView * recordingStartView;

@property BOOL recording;
@property BOOL ready;
@property BOOL paused;
@property BOOL finishRecording;
@property BOOL puttingTogether;

@property (strong,nonatomic) UIActionSheet *actionSheet;
@property (strong,nonatomic) NSOperationQueue* queue;
@property(strong,nonatomic) NSFetchedResultsController * fetchedController;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;
@property (strong,nonatomic) NSString * testString;
@property (strong, nonatomic) IBOutlet UISegmentedControl *collectionViewDisplayMode;


- (IBAction)eraseRecording:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)makeScreenShot:(id)sender;
- (IBAction)finishRecording:(id)sender;
- (IBAction)addVideoPreview:(id)sender;
- (IBAction)addNewSlide:(id)sender;
-(void)finishAndPutTogether;
@end

@implementation RecorderViewController
@synthesize recordingScreenView = recordingScreenView;

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    return YES;
}


-(void)configureFetchedController{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *frequest = [[NSFetchRequest alloc]init];
    [frequest setFetchBatchSize:20];
    [frequest setEntity: [NSEntityDescription entityForName:  @"Slide" inManagedObjectContext:appDelegate.managedObjectContext ]];
    [frequest setPredicate: [NSPredicate predicateWithFormat: @"lecture == %@", self.lecture
                             ]];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    [frequest setSortDescriptors:@[sd]];
    _fetchedController = nil;
    _fetchedController = [[NSFetchedResultsController alloc]initWithFetchRequest:frequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:Nil cacheName:nil];
    _datasource  = [[TJLFetchedResultsSource alloc]initWithFetchedResultsController:_fetchedController  delegate:self andCellID:@"cell"];
    

    self.collectionView.dataSource = _datasource;
    self.collectionView.delegate = self;
    _slideAPI = [[SlideAPI alloc]init];

}

- (IBAction)dismiss:(id)sender {
    [self finishRecording:self];
    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark Lecture APIs
//adds new slide
- (IBAction)addNewSlide:(id)sender {
    //mark previous slide as unselected
//    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.example.gcd.MySerialDispatchQueue", NULL);
//    dispatch_async(mySerialDispatchQueue, ^{
//        Slide * slide = [LectureAPI addNewSlideToLecture:self.lecture afterSlide:self.currentSlide];
//        for(int i=0; i<self.lecture.slides.count;i++){
//            [(Slide *) self.lecture.slides.allObjects[i] setSelected: @0];
//            [SlideAPI save];
//            
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self loadSlide:slide];
//            
//        });
//        
//    });
//    
    Slide * slide = [LectureAPI addNewSlideToLecture:self.lecture afterSlide:self.currentSlide];
    for(int i=0; i<self.lecture.slides.count;i++){
        [(Slide *) self.lecture.slides.allObjects[i] setSelected: @0];
        [SlideAPI save];
        
    }
     [self loadSlide:slide];
   
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
        [self loadSlide:lecture.slides.allObjects.firstObject];
    }
}




-(void)loadSlide:(Slide *)slide{
   //if slide contains video, display it
    _currentSlide.selected = @0;
    slide.selected= @1;
    _currentSlide = slide;
    [SlideAPI save];

    [self.datasource updateContent];
    
    if(slide.video.length>0){
        [self.view addSubview:self.webVideoView];
        self.webVideoView.frame = self.recordingScreenView.frame;
        [self.webVideoView loadVideoWithURL:[NSURL fileURLWithPath: slide.url]];
        
        [self.view addSubview: self.sideControls];
        
    }
    else{
        [self.webVideoView removeFromSuperview];
        [self clearBoard:nil];
    }

    
}


-(void)finishAndPutTogether{
    
    NSString * path = [IOHelper getRandomFilePath];
    NSArray * video = [self.currentSlide.videoFiles allObjects];
    NSArray * audio = [self.currentSlide.audioFiles allObjects];
    //self.currentSlide.se
      frameCounter=0;
    //finish it only if video and audio exist
    if(video.count> 0 && audio.count>0){
        [ioHelper putTogetherVideo:video andAudioPieces:audio andCompletionBlock:^(BOOL success,CMTime duration, Slide *slide, NSString * path) {
          
            if(success){
                
                slide.duration = [NSNumber numberWithInt:CMTimeGetSeconds(duration)] ;
                slide.url = path;
                
                NSError * error;
                if(error){
                    NSLog(@"Error %@",error.debugDescription);
                }
                [ioHelper cleanFiles:slide.videoFiles.allObjects];
                [ioHelper cleanFiles:slide.audioFiles.allObjects];
                slide.videoFiles = nil;
                slide.audioFiles = nil;
                
                [SlideAPI save];
               
                [self performSelectorOnMainThread:@selector(loadSlide:) withObject:slide waitUntilDone:NO];

            }
            else{
          
            }
        } forSlide:self.currentSlide saveAtPath:path];
    
    }
    
   
   }



-(void)stopRecording{
    if([durationTimer isValid]){
        [durationTimer invalidate];
        durationTimer =NULL;
    }
    
    [recordingScreenView performSelector:@selector(stopRecording)];
    [_ar performSelector:@selector(stopRecording)];

}

//Finish recording slide.
-(IBAction)finishRecording:(id)sender
{
   
    self.finishRecording = YES;
    [self stopRecording];
}


-(void)record{
    if(_paused==YES||_recording==NO){
        {
            if(!_ready)
            {
                self.informationLabel.text = @"Recorder is not ready yet.Please try again.";
                NSLog(@"Not ready yet");
            }
            else
            {
                [recordingScreenView performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
                [_ar performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
                _recording = YES;
                _paused = NO;
                _ready = NO;
                
                _recordingStartView = [[UIView alloc]initWithFrame:self.view.bounds];
                _recordingStartView.backgroundColor = [UIColor darkGrayColor];
                
                UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(281,10,553,40)];
                [label setFont:[UIFont systemFontOfSize:20]];
                [label setText:@""];
                
                label.backgroundColor =  [UIColor darkGrayColor];
                label.textColor = [UIColor lightGrayColor];
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 2;
                label.center = _recordingStartView.center;
                label.contentMode = UIViewContentModeCenter;
                label.textAlignment = NSTextAlignmentCenter;
                
                [_recordingStartView addSubview:label];
                [self.view addSubview: _recordingStartView];
                [_recordingStartView addSubview:activityIndicator];
                [activityIndicator startAnimating];
                
                
                
            }
        }
    }


}


-(IBAction)startRecording:(id)sender
{
    // so recording is about to start:
    if(self.currentSlide.video.length >0){
    UIAlertView * alertV = [[UIAlertView alloc]initWithTitle:@"Lecture Capture" message:@"This slide contains the video, what would you like to do? " delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite it with a new recording", nil];
   
    [[alertV rac_buttonClickedSignal]subscribeNext:^(NSNumber * x) {
    
        if(x.integerValue==0){
            
            return;
        }
        else{
            //remove the video and audio objects from the current slide
            [self.currentSlide removeAudioFiles:self.currentSlide.audioFiles];
            [self.currentSlide removeVideoFiles:self.currentSlide.videoFiles];
            self.currentSlide.audio = nil;
            self.currentSlide.video = nil;
            self.currentSlide.duration =@0;
            self.currentSlide.size=@0;
            self.currentSlide.thumbnail = nil;
            
            [self.webVideoView removeFromSuperview];

            [SlideAPI save];
            [self record];
        
        }
  
    }];
     [alertV show];
    }else{
        [self record];

    }

    
}
- (IBAction)changeLayout:(id)sender {
   
    
    
    if(CGRectEqualToRect(self.collectionView.frame,defaultRect)){
        self.collectionView.frame = self.recordingScreenView.frame;
    }
    else{
        self.collectionView.frame = defaultRect;
    }
    
      [self.view addSubview: self.sideControls];
    
}

-(IBAction)pauseRecording:(id)sender
{

    if(!_paused){
        [self stopRecording];
        _paused = YES;
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



-(void)dismissMe:(NSString *) message{
    [activityIndicator stopAnimating];
    if(message){
    UIAlertView * alert= [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    }
    if(interrupted){
        [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
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
#warning they can't do it if video is on.
    
    
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
    _ready = YES;
}

-(void)recordingInterrupted{
    interrupted = YES;
    [self pauseRecording:nil];
}


#pragma mark - TJLFetchedResultsSourceDelegate & Collection View

-(void)didUpdateObjectAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView  reloadItemsAtIndexPaths:@[indexPath]];
    [self.collectionView reloadData];
    
}

- (void)didInsertObjectAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *strongCollectionView = self.collectionView;
    [strongCollectionView insertItemsAtIndexPaths:@[indexPath]];
    if(indexPath.row != 0) {
        [strongCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //show slide on the screen
   // Slide * s = [_fetchedController objectAtIndexPath:indexPath];
    self.currentSlide.selected = @0;
    self.currentSlide = [_fetchedController objectAtIndexPath:indexPath];
    self.currentSlide.selected = @1;
    
    [SlideAPI save];
    
    [self loadSlide:[_fetchedController objectAtIndexPath:indexPath]];

    
}

-(void)recordingStarted{

    recordingScreenView.recording = YES;
    AudioFile *  lastAudioObject = (AudioFile *) [self.currentSlide.audioFiles.allObjects  lastObject];
    
    if([_ar.recorderFilePath isEqualToString:lastAudioObject.path])
    {
        
        
    }
    else{
        
        [self.currentSlide addAudioPiece:_ar.recorderFilePath];
    }
    
    VideoFile* lastVideoObject = [self.currentSlide.videoFiles.allObjects   lastObject];
    
    if([recordingScreenView.outputPath isEqualToString: lastVideoObject.path])
    {
    
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
    [_recordingStartView removeFromSuperview];
    [activityIndicator stopAnimating];

}

CGRect defaultRect;
#pragma mark view management
- (void)viewDidLoad
{
    [super viewDidLoad];

    _paused = NO;
    _recording= NO;
    self.collectionView.draggable = YES;
    defaultRect = self.collectionView.frame;
    ioHelper  = [[IOHelper alloc]init];
    _ar = [[AudioRecorder alloc]init];

    self.lectureNameTextField.delegate = self;
    RAC(self, ready) =[RACSignal
                       combineLatest:@[RACObserve(self, recordingScreenView.ready),RACObserve(self, ar.ready)]
                       reduce:^(NSNumber *ar, NSNumber *mp) {
                           BOOL k = ar.boolValue & mp.boolValue;
                            
                           return [NSNumber numberWithBool:k] ;
                       }];
    
//Preparing to finish recording and put files together we are using dummy bool for now
    @weakify(self);
RAC(self, puttingTogether) =[RACSignal
                       combineLatest:@[RACObserve(recordingScreenView, videoWriter.status),RACObserve(_ar, completed)]
                       reduce:^(NSNumber *mp, NSNumber *ar){
                           @strongify(self);
                           
                         //  NSLog(@" MP is %@",mp);
                         // NSLog(@" AR is %@",ar);
                           BOOL k = ar.boolValue==true && mp.integerValue==AVAssetWriterStatusCompleted;
                           
                           if(self.finishRecording && k){
                           //    NSLog(@"Calling finish and put together %@ %@",_ar,recordingScreenView);
                               self.finishRecording = NO;
                               [self finishAndPutTogether];
                           }
                           
                           return [NSNumber numberWithBool:k] ;
                       }];
    
//Starting Recording
 RAC(self,testString)= [RACSignal
     combineLatest:@[RACObserve(self, recordingScreenView.outputPath),RACObserve(self, ar.recorderFilePath)]
     reduce:^(NSString *ar, NSString *mp) {
      
         if(ar && mp){
             [self recordingStarted];
         }


         return  @"";
     }];


//Monitoring Recording
RAC(self,recording) =[RACSignal
                          combineLatest:@[RACObserve(self, recordingScreenView.recording),RACObserve(self, ar.isRecording)]
                          reduce:^(NSNumber *ar, NSNumber *mp) {
                              BOOL k = ar.boolValue & mp.boolValue;
                            
                              return [NSNumber numberWithBool:k] ;
                          }];

    
//Reacting to changes

    [RACObserve(self, self.recording)subscribeNext:^(NSNumber * x) {
        @strongify(self);
        self.informationLabel.backgroundColor = [UIColor redColor];
        self.informationLabel.textColor = [UIColor whiteColor];
      
        if (x.boolValue) {
            self.informationLabel.text = @"";
            [self.informationLabel removeFromSuperview];
        }
        else{
            self.informationLabel.text = @"Press on the Record button to start recording.";
            [self.view addSubview:self.informationLabel];
        }
        self.informationLabel.frame = CGRectMake(0,0,CGRectGetWidth(self.view.frame),30);
       
    }];

    
    _photoPicker = [[ImagePhotoPicker alloc]init];
    frameCounter =0;
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    scrollViewScreenshots =[[NSMutableArray alloc]initWithCapacity:0];
    recordingScreenView.delegate=self;
   
    
    [scrollView setContentSize:scrollView.frame.size];
   
    
    vp = [[VideoPreview alloc]initWithFrame:CGRectZero];
    cp=[[ILColorPickerDualExampleController alloc]initWithNibName:@"ILColorPickerDualExampleController" bundle:nil];
    cp.delegate = self;
    
    _webVideoView = [[WebVideoView alloc]initWithFrame:recordingScreenView.frame];
    
    
    [self configureFetchedController];
    
    _ready = YES;

    
    
    
    
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
