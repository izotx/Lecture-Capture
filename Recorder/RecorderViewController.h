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
__weak IBOutlet UIActivityIndicatorView *activityIndicator;
    UIPopoverController * colorPopover;
    UIPopoverController * cameraPopover;
    IBOutlet UIBarButtonItem *cameraBarButton;
    UIActionSheet * photoAction;
    IBOutlet UIImageView * testImageView;
}
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *colorBarButton;


@property(nonatomic,retain)NSString * movie_title;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@property BOOL eraseMode;

- (IBAction)changeBrushSize:(id)sender;
- (IBAction)pickColorFor:(id)sender;
- (IBAction)changeBackground:(id)sender;
- (IBAction)eraserOnOff:(id)sender;

- (IBAction)redoAction:(id)sender;
- (IBAction)undoAction:(id)sender;

-(void)putFilesTogether;

@end
