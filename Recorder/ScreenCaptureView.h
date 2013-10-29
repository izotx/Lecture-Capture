#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PaintView.h"


@protocol ScreenCaptureViewDelegate <NSObject>
- (void) recordingFinished:(BOOL)success;
- (void) recordingInterrupted;
- (void) recordingStartedNotification;
@optional
-(void)previewUpdated:(UIImage *)img;
@end


#import "CaptureSessionManager.h"
@interface ScreenCaptureView : UIView<AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate> {
	//video writing
	AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
	
	//recording state
	NSDate* startedAt;
	void* bitmapData;
    NSString *outputPath;
}

//for recording video
- (bool) startRecording;
- (void) stopRecording;

//
-(void)addVideoPreview;
-(void)removeVideoPreview;
-(void)switchCamera;

//for accessing the current screen and adjusting the capture rate, etc.
@property(retain) UIImage* currentScreen;
@property(assign) float frameRate;
@property(nonatomic, assign) id<ScreenCaptureViewDelegate> delegate;
@property(nonatomic,retain) NSString *outputPath;
@property(nonatomic,strong) PaintView * paintView;
@property(nonatomic,strong) UIImageView * backgroundView;
@property(nonatomic,strong) UIImage * vi;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic,strong) CaptureSessionManager * csm;
@property CGRect  videoPreviewFrame;
@property BOOL fullScreen;
@property BOOL rotatePreview;
@property BOOL recording;


@end