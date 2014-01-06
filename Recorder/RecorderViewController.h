//
//  RecorderViewController.h
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenCaptureView.h"
#import "PaintView.h"
#import "AudioRecorder.h"
#import "ScreenView.h"
#import "ILColorPickerDualExampleController.h"
#import "TJLFetchedResultsSource.h"


@class Lecture;
@class Slide;

@interface RecorderViewController : UIViewController <ScreenCaptureViewDelegate,ScreenShotDelegate,ColorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate>
{
    IBOutlet UIImageView *backgroundView;
__weak IBOutlet UIScrollView *scrollView;
__weak IBOutlet UIActivityIndicatorView *activityIndicator;
    UIPopoverController * colorPopover;
    UIActionSheet * photoAction;
    IBOutlet UIImageView * testImageView;
    IBOutlet UIBarButtonItem *cameraBarButton;
}

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *colorBarButton;
@property (strong, nonatomic) Lecture * lecture;
@property (strong, nonatomic) IBOutlet ScreenCaptureView *recordingScreenView;
@property BOOL eraseMode;
@property (strong, nonatomic) IBOutlet UITextField *lectureNameTextField;


- (IBAction)changeBrushSize:(id)sender;
- (IBAction)pickColorFor:(id)sender;
- (IBAction)changeBackground:(id)sender;
- (IBAction)eraserOnOff:(id)sender;

- (IBAction)redoAction:(id)sender;
- (IBAction)undoAction:(id)sender;

-(void)resizeMe;
-(void)dismissPreview;


@end
