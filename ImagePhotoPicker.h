//
//  ImagePhotoPicker.h
//  Pods
//
//  Created by sadmin on 10/4/13.
//
//

#import <Foundation/Foundation.h>

@interface ImagePhotoPicker : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (copy) void (^finishedBlock) (UIImage * img);
- (IBAction)showImagePickerForPhotoPicker:(id)sender withCompletionBlock:(void (^) (UIImage * img))finishedBlock andBarButtonItem:(UIBarButtonItem *)item;

@end
