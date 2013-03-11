//
//  RecorderViewController.h
//  Recorder
//
//  Created by Janusz Chudzynski on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenCaptureView.h"
#import "PaintView.h"
#import "AudioRecorder.h"
#import "Video.h"
#import "ScreenView.h"
#import <iAd/iAd.h>
#import "ILColorPickerDualExampleController.h"

@interface RecorderViewController : UIViewController <ScreenCaptureViewDelegate,ScreenShotDelegate,ADBannerViewDelegate, ColorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *backgroundView;
    
__weak IBOutlet ScreenCaptureView *recordingScreenView;
__weak IBOutlet UIScrollView *scrollView;
__weak IBOutlet UIButton *stopOrRecordButton;
__weak IBOutlet UIActivityIndicatorView *activityIndicator;
    UIPopoverController * colorPopover;
    UIPopoverController * cameraPopover;
    IBOutlet UIButton *cameraBarButton;
    UIActionSheet * photoAction;
    IBOutlet UIImageView * testImageView;
    
}
@property(nonatomic,retain)NSString * movie_title;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
- (IBAction)cancelExporting:(id)sender;
- (IBAction)changeBrushSize:(id)sender;
- (IBAction)pickColorFor:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
