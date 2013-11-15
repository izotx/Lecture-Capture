//
//  AVCaptureHelper.m
//  AVCaptureFun
//
//  Created by DJMobile INC on 10/31/12.
//  Copyright (c) 2012 DJMobile INC. All rights reserved.
//

#import "AVCaptureHelper.h"

@implementation AVCaptureHelper
@synthesize captureSession;
@synthesize videoInput;
@synthesize avOutput;
@synthesize videoDataOutput;
@synthesize target;



-(id)init{
    if(self = [super init])
    {
        [self setUpSession];
    }
    return self;
}


-(void)setUpSession{
    captureSession = [[AVCaptureSession alloc] init];

    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
   // videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];
   // avOutput = [[AVCaptureVideoDataOutput alloc]init];
     
//    avOutput.alwaysDiscardsLateVideoFrames = YES;
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
//    [avOutput setSampleBufferDelegate:self queue:queue];
//    
//    avOutput.videoSettings =
//    [NSDictionary dictionaryWithObject:
//     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
//                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//
//    
    
    if(videoInput)
    {
        [captureSession addInput:videoInput];
    }
//    if ([captureSession canAddOutput:avOutput])
//    {
//       [captureSession addOutput:avOutput];
//    }
//    else
//    {
//        NSLog(@"Couldn't add video output");
//    }
    
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
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
    {
        [captureSession addOutput:videoDataOutput];
        NSLog(@"We just added video data output ");
    }
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




-(void)start{
    if(captureSession){
    [self.captureSession startRunning];
    
        NSLog(@"Start");
    }
    
}

-(void)stop{
    [captureSession stopRunning];
}



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
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}



- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}



- (BOOL) toggleCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        else
            goto bail;
        
        if (newVideoInput != nil) {
            [[self captureSession] beginConfiguration];
            [[self captureSession] removeInput:[self videoInput]];
            if ([[self captureSession] canAddInput:newVideoInput]) {
                [[self captureSession] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self captureSession] addInput:[self videoInput]];
            }
           // [[self session] commitConfiguration];
            success = YES;

        } else if (error) {
            /*
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
             */
        }
    }
    
bail:
    return success;
}

#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}








@end
