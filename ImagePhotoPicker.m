//
//  ImagePhotoPicker.m
//  Pods
//
//  Created by sadmin on 10/4/13.
//
//

#import "ImagePhotoPicker.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIImage+Resizing.h"

@interface ImagePhotoPicker()
@property(nonatomic,strong)UIImagePickerController * imagePickerController;
@property(nonatomic,strong) UIViewController * vc;
@end

@implementation ImagePhotoPicker


#pragma mark photo picker
- (IBAction)showImagePickerForPhotoPicker:(id)sender withCompletionBlock:(void (^) (UIImage * img))finishedBlock;{
    
    self.vc = sender;
    self.finishedBlock = [finishedBlock copy];

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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
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
    [self.vc presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image =  [image imageByScalingProportionallyToSize:CGSizeMake(200, 200)];
    
   // [self finishAndUpdate:image];
    self.finishedBlock(image);
//    [self imagePickerControllerDidCancel:picker];
    [self.vc dismissViewControllerAnimated:YES completion:^{
//        
    }];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    
    [self.vc dismissViewControllerAnimated:YES completion:^{

    }];
}




@end
