#import "ScreenCaptureView.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "VideoPreview.h"

#import "UIImageAddition.h"
@interface ScreenCaptureView()
@property BOOL paused;
@property CMTime currentCMTime;
@property CGLayerRef destLayer;
@property CGContextRef destContext;
@property BOOL layerReady;


- (void) writeVideoFrameAtTime:(CMTime)time;
@end

@implementation ScreenCaptureView

@synthesize currentScreen, frameRate, delegate;
@synthesize paintView;
@synthesize outputPath;
@synthesize vi;

@synthesize panGesture;
@synthesize csm;
@synthesize videoPreviewFrame;
@synthesize fullScreen;
@synthesize rotatePreview;



- (void) initialize {
    paintView = [[PaintView alloc]initWithFrame:self.bounds];
    paintView.backgroundColor = [UIColor blackColor];
	[self addSubview:self.paintView];
    self.clearsContextBeforeDrawing = YES;

    self.currentScreen = nil;
	self.frameRate = 35.0f;     //10 frames per seconds
	
	videoWriter = nil;
	videoWriterInput = nil;
	avAdaptor = nil;
	startedAt = nil;
	bitmapData = NULL;
    self.userInteractionEnabled = YES;
    
    csm = [[CaptureSessionManager alloc]init];
    csm.target = self;
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseAction:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAction:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Preparing for drawing in background
    CGFloat contentScale = [[UIScreen mainScreen]scale];
    CGSize layerSize = CGSizeMake(self.bounds.size.width * contentScale,self.bounds.size.height * contentScale);
    _destLayer = CGLayerCreateWithContext([self createBitmapContextOfSize:self.bounds.size], layerSize, NULL);
    _destContext = CGLayerGetContext(_destLayer);
    CGContextScaleCTM(_destContext, contentScale, contentScale);
    _layerReady = NO;
    
  
    
}

-(void)pauseAction:(NSNotification * )notification{
    if(_recording){
    if(  [[csm captureSession]isRunning]){
        [[csm captureSession] stopRunning];
     }
        [delegate recordingInterrupted];

    }
}

-(void)activeAction:(NSNotification * )notification{
    //paused=NO;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}



- (CGContextRef) createBitmapContextOfSize:(CGSize) size {
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	bitmapBytesPerRow   = (size.width * 4);
	bitmapByteCount     = (bitmapBytesPerRow * size.height);
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (bitmapData != NULL) {
		free(bitmapData);
	}
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) {
		CGColorSpaceRelease(colorSpace);
        return NULL;
	}
	
	context = CGBitmapContextCreate (bitmapData,
									 size.width,
									 size.height,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
	
	CGContextSetAllowsAntialiasing(context,NO);
	if (context== NULL) {
		free (bitmapData);
		bitmapData = NULL;
		fprintf (stderr, "Context not created!");
		CGColorSpaceRelease(colorSpace);
        return NULL;
	}
	CGColorSpaceRelease(colorSpace);
	
	return context;
}


- (void) drawRect:(CGRect)rect {
    
#pragma warning add operation queue
    NSDate* start = [NSDate date];
	   
	float delayRemaining=0;
	//not sure why this is necessary...image renders upside-down and mirrored
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(_destContext, flipVertical);
    UIImage* background =   paintView.image;
    
    self.currentScreen = background;
    if([csm.captureSession isRunning]){
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [background drawInRect:self.frame];
        
        CGRect tframe;
        CGRect videoPreviewBackgroundFrame;
        if(fullScreen){
            tframe = self.frame;
        }
        else{
            tframe = videoPreviewFrame;
        }
        
        
        float h = videoPreviewFrame.size.height;
        float w = videoPreviewFrame.size.width;
        
        float ow = self.frame.size.width;
        float oh = self.frame.size.height;
        float dx,dy;
        if(fullScreen){
            dx = (ow - w)/2.0;
            dy = (oh - h)/2.0;
            
        }
        else{
            dx= videoPreviewFrame.origin.x;
            dy= videoPreviewFrame.origin.y;
        }
        
        CGRect tempRect = CGRectMake(dx, dy, w, h);
        //  CGRect fullTempRect = CGRectMake(dx, dy+11, w, h);
        
        float x = tempRect.origin.x;
        float y = tempRect.origin.y;
        
        x = x-(0.1*w)/2.0;
        y = y-(0.1*h)/2.0;
        w = 1.1 * w;
        h = 1.1 * h;
        
        videoPreviewBackgroundFrame = CGRectMake(x,y,w,h);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor grayColor]CGColor]);
        CGContextFillRect(ctx, tframe);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
        CGContextFillRect(ctx, videoPreviewBackgroundFrame);
        
        if(!fullScreen){
            [vi drawInRect:videoPreviewFrame blendMode:kCGBlendModeNormal alpha:1];
        }
        else{
            [vi drawInRect:videoPreviewBackgroundFrame blendMode:kCGBlendModeNormal alpha:1];
        }
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        self.currentScreen = newImage;
    }
    
    
    if (_recording) {
        float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
        [self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000)];
        float processingSeconds = [[NSDate date] timeIntervalSinceDate:start];
        delayRemaining = (1.0 / self.frameRate) - processingSeconds;
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRemaining > 0.0 ? delayRemaining : 0.01];
    }
//        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRemaining > 0.0 ? delayRemaining : 0.01];
}


- (void) cleanupWriter {

	avAdaptor = nil;
	videoWriterInput = nil;
    videoWriter = nil;
	startedAt = nil;
    
    [[csm captureSession]stopRunning];
	
	if (bitmapData != NULL) {
		free(bitmapData);
		bitmapData = NULL;
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationWillResignActiveNotification object:nil];
    NSLog(@"Clean Up Writer");
}

- (void)dealloc {
	[self cleanupWriter];
   
}

- (NSURL*) tempFileURL {
    int ran = arc4random()%100* arc4random();
	self.outputPath = [[NSString alloc] initWithFormat:@"%@/temp_piece%d.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],ran];
	NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:outputPath]) {
		NSError* error;
		if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
			NSLog(@"Could not delete old recording file at path:  %@", outputPath);
		}
	}
	
	return outputURL;
}

-(BOOL) setUpWriter {
    NSLog(@"Set Up Writer");
	NSError* error = nil;
	videoWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL] fileType:AVFileTypeQuickTimeMovie error:&error];
	NSParameterAssert(videoWriter);
	
	//Configure video
	NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithDouble:1024.0*1024.0], AVVideoAverageBitRateKey,
										   nil ];
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:self.frame.size.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:self.frame.size.height], AVVideoHeightKey,
								   videoCompressionProps, AVVideoCompressionPropertiesKey,
								   nil];
	
	videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	
	NSParameterAssert(videoWriterInput);
	videoWriterInput.expectsMediaDataInRealTime = YES;
	NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
	
	avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
	
	//add input
	[videoWriter addInput:videoWriterInput];
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
	[delegate recordingStartedNotification];
	return YES;
}

- (void) completeRecordingSession {
	
    @autoreleasepool {
        NSLog(@"Complete recording session ");
	@try {
        [videoWriterInput markAsFinished];
        NSLog(@"Mark recording as finished ");
    }
    @catch (NSException *exception) {
        NSLog(@" Mark as Finished Failed: %@",[exception debugDescription]);
    }
    @finally {
        
    }

        
    // Wait for the video
	int status = videoWriter.status;
    while (status == AVAssetWriterStatusUnknown) {
		[NSThread sleepForTimeInterval:0.1f];
		 status = videoWriter.status;
	}
        //[videoWriter endSessionAtSourceTime:currentCMTime];
	[videoWriter finishWritingWithCompletionHandler:^{
        [self cleanupWriter];
        id delegateObj = self.delegate;
     
        
        if(videoWriter.status == AVAssetWriterStatusFailed)
        {
            NSLog(@"Video Writer Failed");
        }
            
        if ([delegateObj respondsToSelector:@selector(recordingFinished:)]) {
            [delegateObj performSelectorOnMainThread:@selector(recordingFinished:) withObject:nil waitUntilDone:YES];
        }
        
        }];
	}
}



- (bool) startRecording {
 
	bool result = NO;
	@synchronized(self) {
		if (! _recording) {
			result = [self setUpWriter];
			startedAt = [NSDate date];
			_recording = true;

            [self performSelector:@selector(setNeedsDisplay)];
        }
    
        
	}
	return result;
}

- (void) stopRecording {
	@synchronized(self) {
		if (_recording) {
			_recording = false;
            if([videoWriter respondsToSelector:@selector(finishWritingWithCompletionHandler:)]){
                NSLog(@" Complete Recording session");
                [self completeRecordingSession];
            }
        }
	}
}

-(void) writeVideoFrameAtTime:(CMTime)time {
    
    if(self.paused) return;
    
    if (![videoWriterInput isReadyForMoreMediaData]) {
		  NSLog(@"Not ready for video data");
	}
	else {
		@synchronized (self) {
			UIImage* newFrame = self.currentScreen;
			CVPixelBufferRef pixelBuffer = NULL;
			CGImageRef cgImage = CGImageCreateCopy([newFrame CGImage]);
            
			CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
			
			int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
			if(status != 0){
				//could not get a buffer from the pool
				NSLog(@"Error creating pixel buffer:  status=%d", status);
			}
			// set image data into pixel buffer
			CVPixelBufferLockBaseAddress(pixelBuffer, 0 );
			uint8_t* destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
			CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);  //XXX:  will work if the pixel buffer is contiguous and has the same bytesPerRow as the input data
			
			if(status == 0){
                    BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                    if (!success) NSLog(@"Warning:  Unable to write buffer to video");
             
               // NSLog(@"Write and time : %f",CMTimeGetSeconds(time));
                self.currentCMTime = time;
            }
			//clean up
			CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
			CVPixelBufferRelease( pixelBuffer );
			CFRelease(image);
			CGImageRelease(cgImage);
		}		
	}	
}

//Handling Video Preview
-(void)addVideoPreview{
    if(![[csm captureSession]isRunning])
    {
        [csm addVideoInputFrontCamera:YES];
        [csm addVideoOutput];
        [[csm captureSession] startRunning];

    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage * im = [self imageFromSampleBuffer:sampleBuffer];
    if(self.rotatePreview)
    {
        im = [im imageRotatedByDegrees:180.0];
    }
    self.vi = im;
    [delegate previewUpdated:vi]
    ;}


- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
      // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //NSLog(@"%zu %zu %zu",width,height,bytesPerRow);
    
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(context, flipVertical);
    
    //videoPreviewImage = quartzImage;
    //CGImageRelease(quartzImage);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

-(void)switchCamera{
    [csm addVideoInputFrontCamera:!csm.front];
}

-(void)removeVideoPreview{
    [[csm captureSession] stopRunning];
}




@end