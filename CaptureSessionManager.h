#import <AVFoundation/AVFoundation.h>


@interface CaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    dispatch_queue_t videoDataOutputQueue;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, retain) UIImage *stillImage;
@property(nonatomic,assign) id target;
@property  BOOL front;
- (void)addVideoInputFrontCamera:(BOOL)front;
- (void)addVideoOutput;
@end
