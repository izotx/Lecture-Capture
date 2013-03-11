#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;
@synthesize videoDataOutput;
#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
//		[self setCaptureSession:[[AVCaptureSession alloc] init]];//
        captureSession = [[AVCaptureSession alloc]init];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]] autorelease]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
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
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

- (void)addStillImageOutput 
{
  [self setStillImageOutput:[[[AVCaptureStillImageOutput alloc] init] autorelease]];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
  [[self stillImageOutput] setOutputSettings:outputSettings];
  
  AVCaptureConnection *videoConnection = nil;
  for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
    for (AVCaptureInputPort *port in [connection inputPorts]) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) { 
      break; 
    }
  }
  
  [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{  
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { 
      break; 
    }
	}
  
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection 
                                                       completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) { 
                                                         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                         if (exifAttachments) {
                                                           NSLog(@"attachements: %@", exifAttachments);
                                                         } else { 
                                                           NSLog(@"no attachments");
                                                         }
                                                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
                                                         UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                         [self setStillImage:image];
                                                         [image release];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                       }];
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
[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

if ( [captureSession canAddOutput:videoDataOutput] )
    [captureSession addOutput:videoDataOutput];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    NSLog(@"no VIdeo :((( ");
    // CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Create a UIImage from the sample buffer data
    //    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    //    NSLog(@"Video Output is flowing here : - ) ");
    //    [self performSelectorOnMainThread:@selector(image:) withObject:nil waitUntilDone:NO];
    
}



- (void)dealloc {

	[[self captureSession] stopRunning];

	[previewLayer release], previewLayer = nil;
	[captureSession release], captureSession = nil;
    [stillImageOutput release], stillImageOutput = nil;
    [stillImage release], stillImage = nil;

	[super dealloc];
}

@end
