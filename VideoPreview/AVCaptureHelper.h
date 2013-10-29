//
//  AVCaptureHelper.h
//  AVCaptureFun
//
//  Created by DJMobile INC on 10/31/12.
//  Copyright (c) 2012 DJMobile INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVCaptureHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t videoDataOutputQueue;
}
@property(nonatomic, strong)AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property(nonatomic,strong) AVCaptureVideoDataOutput * avOutput;
@property(nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic,assign) id target;

-(void)start;
-(void)addVideoOutput;

@end
