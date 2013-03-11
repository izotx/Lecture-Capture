//
//  AVCaptureHelper.h
//  AVCaptureFun
//
//  Created by Janusz Chudzynski on 10/31/12.
//  Copyright (c) 2012 Janusz Chudzynski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVCaptureHelper : NSObject
@property(nonatomic, strong)AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureDeviceInput *videoInput;

@end
