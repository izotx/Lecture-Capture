//
//  PaintView.h
//
//  Created by DJMobile INC on 8/6/12.
//  Copyright (c) 2012 DJMobile INC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintView : UIImageView <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) UIImage * backgroundImage;
@property (nonatomic,strong)  UIImage * startImage;

@property(nonatomic,strong)  UIColor * colorOfBackground;
@property(nonatomic,strong)  UIColor * strokeColor;
@property(nonatomic, assign) int brushSize;
@property(nonatomic,assign)  BOOL eraseMode;
@property(nonatomic,strong)  UIBezierPath * myPath;

//Gestures
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer * pinchGesture;

//Methods
-(void) setBrushStrokeColor:(UIColor *)strokeColor;
-(void) setColorOfBackground:(UIColor *)color;

-(void) setSizeOfBrush:(int)brushSize;
-(void) eraseContext;
-(void) setBackgroundPhotoImage:(UIImage *)image;
-(void) removeBackgroundPhoto;
-(void) undo;

- (void)prepareForImageCapture;


@end
