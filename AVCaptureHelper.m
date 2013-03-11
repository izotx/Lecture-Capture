//
//  AVCaptureHelper.m
//  AVCaptureFun
//
//  Created by Janusz Chudzynski on 10/31/12.
//  Copyright (c) 2012 Janusz Chudzynski. All rights reserved.
//

#import "AVCaptureHelper.h"

@implementation AVCaptureHelper
@synthesize captureSession;
@synthesize videoInput;

-(id)init{
    if(self = [super init])
    {
        [self setUpSession];
    }
    return self;
}


-(void)setUpSession{
    captureSession = [[AVCaptureSession alloc] init];
    //AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];

    if(videoInput)
    {
        [captureSession addInput:videoInput];
        NSLog(@"Added Video Input");
    }

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
