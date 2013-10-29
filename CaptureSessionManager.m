#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;
@synthesize videoDataOutput;
@synthesize target;
#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
//		[self setCaptureSession:[[AVCaptureSession alloc] init]];//
        captureSession = [[AVCaptureSession alloc]init];
        captureSession.sessionPreset = AVCaptureSessionPresetHigh;
	}
	return self;
}


- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSArray * array =  [captureSession inputs];
    for (int i = 0; i<array.count; i++) {
        if([[array objectAtIndex:i] isKindOfClass:[AVCaptureDeviceInput class]])
        {
            [captureSession removeInput:[array objectAtIndex:i]];
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
 ;
        if (!error) {
            
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
                self.front = front;
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
                 self.front = front;
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}



-(void)addVideoOutput{
videoDataOutput = [AVCaptureVideoDataOutput new];

// we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
[videoDataOutput setVideoSettings:rgbOutputSettings];
[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)

// create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
// a serial dispatch queue must be used to guarantee that video frames will be delivered in order
// see the header doc for setSampleBufferDelegate:queue: for more information
videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
[videoDataOutput setSampleBufferDelegate:self.target queue:videoDataOutputQueue];

if ( [captureSession canAddOutput:videoDataOutput] )
    [captureSession addOutput:videoDataOutput];
}



@end
