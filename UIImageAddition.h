//
//  UIImageAddition.h
//  Lecture Capture
//
//  Created by sadmin on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UIImage (Extras)
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end;

@interface UIImageAddition : NSObject
- (UIImage *)scaleAndRotateImage:(UIImage *)image forMaxResolutionWidth:(int)width andMaxResolutionHeight:(int)height ;
-(UIImage *)resizeImage:(UIImage *)image andDestWidth:(int)destWidth andDestHeight:(int) destHeight;
-(UIImage *)scaleImage:(UIImage *)image toHeight:(int)maxHeight andWidth:(int)maxWidth;


@end
