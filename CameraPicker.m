//
//  CameraPicker.m
//  Frames Sharing
//
//  Created by Janusz Chudzynski on 4/3/13.
//  Copyright (c) 2013 Blue Plover Productions. All rights reserved.
//

#import "CameraPicker.h"

@implementation CameraPicker


-(id)init{
    self = [super init];
    if(self )
    {
    
    }
    return self;
}

#pragma mark Camera
#pragma mark camera methods
UIPopoverController * cameraPopoverController;


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate from:(UIView *)view  picker:(BOOL)picker andPopover:(UIPopoverController *)_cameraPopoverController {
    if(!picker){
        if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO))
        {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"We were not able to find a camera on this device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return NO;
        }
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if(!picker){
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
     cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
    }
    else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:
                              UIImagePickerControllerSourceTypePhotoLibrary];
    
    }
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = controller;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        cameraPopoverController = _cameraPopoverController;
        if(!cameraPopoverController.isPopoverVisible){
            cameraPopoverController=[[UIPopoverController alloc]initWithContentViewController:cameraUI];
            [cameraPopoverController presentPopoverFromRect:view.frame inView:controller.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else{
        [controller presentViewController:cameraUI animated:YES completion:nil];
        
    }
    return YES;
}


@end
