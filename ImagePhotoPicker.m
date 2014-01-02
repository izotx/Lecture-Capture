//
//  ImagePhotoPicker.m
//  Pods
//
//  Created by sadmin on 10/4/13.
//
//

#import "ImagePhotoPicker.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NonRotatingImagePicker.h"
@interface NonRotatingUIImagePickerController : UIImagePickerController

@end

@implementation NonRotatingUIImagePickerController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape| UIInterfaceOrientationMaskPortrait;
}

@end

@interface ImagePhotoPicker()
@property(nonatomic,strong)UIImagePickerController * imagePickerController;
@property(nonatomic,strong)  UIViewController * vc;
@property (nonatomic,strong) UIPopoverController * cameraPopover;
@property (nonatomic,strong) UIBarButtonItem * cameraBarButton;
@end

@implementation ImagePhotoPicker


#pragma mark photo picker
- (IBAction)showImagePickerForPhotoPicker:(id)sender withCompletionBlock:(void (^) (UIImage * img))finishedBlock andBarButtonItem:(UIBarButtonItem *)item{
    
    self.vc = sender;
    self.finishedBlock = [finishedBlock copy];
    self.cameraBarButton  = item;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    [sheet showInView: self.vc.view];
    RACSignal *actionSignal = [[sheet.rac_buttonClickedSignal map:^id(NSNumber *value) {
        if(value.integerValue == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return @(UIImagePickerControllerSourceTypeCamera);
        }
        else if(value.integerValue == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            return @(UIImagePickerControllerSourceTypePhotoLibrary);
        }
        else return @(-1);
    }]filter:^BOOL(NSNumber *value) {
        return value.integerValue != -1;
    }];
    
    [self rac_liftSelector:@selector(showImagePickerForSourceType:) withSignals:actionSignal, nil];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[NonRotatingUIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        imagePickerController.showsCameraControls = YES;
        
    }
    

    self.imagePickerController = imagePickerController;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        if(!_cameraPopover.isPopoverVisible){
            _cameraPopover=[[UIPopoverController alloc]initWithContentViewController:self.imagePickerController];
            [_cameraPopover presentPopoverFromBarButtonItem:_cameraBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
        else{
            [_cameraPopover dismissPopoverAnimated:YES];
        }
        

    }
    else{
        [self.vc presentViewController:self.imagePickerController animated:YES completion:nil];

    }
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    self.finishedBlock(image);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
       [_cameraPopover dismissPopoverAnimated:YES];
    }
    else{
        [self.vc dismissViewControllerAnimated:YES completion:^{}];
    }

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.finishedBlock(NULL);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [_cameraPopover dismissPopoverAnimated:YES];
    }
    else{
        [self.vc dismissViewControllerAnimated:YES completion:^{}];
        
    }
}




@end
