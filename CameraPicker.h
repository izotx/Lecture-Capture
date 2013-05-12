//
//  CameraPicker.h
//  Frames Sharing
//
//  Created by Janusz Chudzynski on 4/3/13.
//  Copyright (c) 2013 Blue Plover Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraPicker : NSObject


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate from:(UIView *)view  picker:(BOOL)picker andPopover:(UIPopoverController *)cameraPopoverController;
@end
