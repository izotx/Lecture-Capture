//
//  PaintView.m
//  CoreImageisFun
//
//  Created by Janusz Chudzynski on 8/6/12.
//  Copyright (c) 2012 Janusz Chudzynski. All rights reserved.
//

#import "PaintView.h"
//We need to store:
//Size, stroke
//It crashes after some time of using it:



@implementation PaintView
@synthesize colorOfBackground,strokeColor;
@synthesize brushSize;
@synthesize backgroundImage, startImage;
@synthesize myPath;

@synthesize panGesture;
@synthesize pinchGesture; 
@synthesize backgroundScreen;

NSMutableArray * paths;
NSMutableArray * colors;
NSMutableArray * sizes;
float scale; 
CGPoint translation;

- (id)initWithFrame:(CGRect)frame
{
 
    translation = CGPointZero;
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        UIGraphicsBeginImageContext(self.frame.size);
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        startImage =self.image;
        UIGraphicsEndImageContext();

        self.backgroundColor=[UIColor whiteColor];
        self.userInteractionEnabled=YES;
        
        brushSize=10;
        UIBezierPath * path= [UIBezierPath bezierPath];
        self.myPath = path;
        
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=brushSize;
        strokeColor=[UIColor redColor];
        
        colors= [[NSMutableArray alloc]initWithCapacity:0];
        paths= [[NSMutableArray alloc]initWithCapacity:0];
        sizes = [[NSMutableArray alloc]initWithCapacity:0];
        // Gestures
        
        
        pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchMethod:)];
        [pinchGesture setDelegate:self];
        [self addGestureRecognizer:pinchGesture];

        panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMethod:)];
        panGesture.minimumNumberOfTouches=2;
        panGesture.maximumNumberOfTouches=2;
        [panGesture setDelegate:self];
        [self addGestureRecognizer:panGesture];
        scale =1;
    }
    return self;
}

-(void)panMethod:(UIPanGestureRecognizer * )gesture{
//    CGPoint tempT= [gesture translationInView:self] ;
//    tempT = CGPointZero;
//    translation.x  = translation.x + tempT.x;
//    translation.y  = translation.y + tempT.y;
        
    translation = [gesture translationInView:self] ;
    
    [self drawImageAndLines];
}


-(void)pinchMethod:(UIPinchGestureRecognizer * )pr{
    scale = pr.scale;
    [self drawImageAndLines];
}



-(void)drawImageAndLines{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.backgroundScreen)
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.backgroundScreen.size.height);
        CGContextScaleCTM(context, scale, -scale);
        CGContextDrawImage(context, [self calculateFrameForImage:backgroundScreen], self.backgroundScreen.CGImage);
        CGContextRestoreGState(context);
        
    }

    if(self.colorOfBackground)
    {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, colorOfBackground.CGColor);
        CGContextFillRect(context, self.bounds);
        CGContextRestoreGState(context);
        NSLog(@"Drawing color of background in draw image and lines");
    }

    if(self.backgroundImage)
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.backgroundImage.size.height);
        CGContextScaleCTM(context, scale, -scale);
        CGRect frame = [self calculateFrameForImage:backgroundImage];
        CGContextDrawImage(context, frame, self.backgroundImage.CGImage);
        /*
        CGContextSetStrokeColorWithColor(context, [[UIColor purpleColor]CGColor]);
        CGContextMoveToPoint(context, frame.origin.x, -1000);
        CGContextAddLineToPoint(context, frame.origin.x, 1000);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor]CGColor]);
        CGContextMoveToPoint(context, 100/scale, -1000);
        CGContextAddLineToPoint(context, 100/scale, 1000);
        CGContextMoveToPoint(context, 200/scale, -1000);
        CGContextAddLineToPoint(context, 200/scale, 1000);
        CGContextMoveToPoint(context, 300/scale, -1000);
        CGContextAddLineToPoint(context, 300/scale, 1000);
        CGContextMoveToPoint(context, 400/scale, -1000);
        CGContextAddLineToPoint(context, 400/scale, 1000);
        */
        
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
       
        
        
        NSLog(@"Drawing background image in draw image and lines");
        
        
        

    }
    int i=0;
    for(UIBezierPath * p in paths)
    {
        
        myPath.lineWidth = [[sizes objectAtIndex:i]floatValue];
        [[colors objectAtIndex:i]setStroke];
        [p stroke];
        
        i++;
    }
    
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}




-(void)registerValues{
    [paths addObject:myPath];
    NSValue * sizeVal = [NSNumber numberWithFloat:brushSize];
    [sizes addObject:sizeVal];
    [colors addObject:strokeColor];
}


-(CGRect ) calculateFrameForImage:(UIImage *)image
{
   float imageWidth = image.size.width;
   float imageHeight = image.size.height;
        
   float selfFrameWidth = self.frame.size.width;
   float selfFrameHeight = self.frame.size.height;

   
    
   NSLog(@"Scale:%f %f ABS %f %f  translation %f, scaled x is %f ",scale,  abs(selfFrameHeight-imageHeight)/2.0, imageWidth * scale,(selfFrameWidth - imageWidth*scale)/2.0,(selfFrameWidth - imageWidth*scale)/2.0 + translation.x, ((selfFrameWidth - imageWidth*scale)/2.0 + translation.x)*scale);

   //CGRect frame = CGRectMake(((selfFrameWidth - imageWidth)/2.0 + translation.x ) / scale, 0-translation.y/ scale, imageWidth/scale, imageHeight/scale);
   CGRect frame = CGRectMake(((selfFrameWidth - imageWidth)/2.0 + translation.x ) / scale, 0-translation.y/ scale, imageWidth, imageHeight);
    
    return frame;
}

-(void)eraseContext{
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [paths removeAllObjects];
    [colors removeAllObjects];
    [sizes removeAllObjects];

    CGContextClearRect(context, self.frame);
    if(self.colorOfBackground)
    {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, colorOfBackground.CGColor);
        CGContextFillRect(context, self.bounds);
        CGContextRestoreGState(context);
    }
    
    if(self.backgroundImage){
        CGContextSaveGState(context);
      
        CGContextTranslateCTM(context, 0.0f, self.backgroundImage.size.height);
        CGContextScaleCTM(context, scale, -scale);
        
        CGContextDrawImage(context, [self calculateFrameForImage:backgroundImage], self.backgroundImage.CGImage);
        CGContextRestoreGState(context);
        
  
        
        
    }
    else{
        self.image =self.startImage;
    }
        self.image = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
}


#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int touchesCount=    [[event allTouches]count];
   NSLog(@"Count is %d ",touchesCount);
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
       
    @autoreleasepool {
        UIBezierPath * path= [UIBezierPath bezierPath];
        self.myPath = path;
    }

    myPath.lineCapStyle=kCGLineCapRound;
    myPath.miterLimit=0;
    myPath.lineWidth=brushSize;
   [myPath moveToPoint:[mytouch locationInView:self]];
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
       
    int touchesCount=    [[event allTouches]count];
    UIGraphicsBeginImageContext(self.frame.size);
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.backgroundScreen)
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.backgroundScreen.size.height);
        CGContextScaleCTM(context, scale, -scale);
        CGContextDrawImage(context, [self calculateFrameForImage:backgroundScreen], self.backgroundScreen.CGImage);
       

        
        CGContextRestoreGState(context);

    }
    if(self.colorOfBackground)
    {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, colorOfBackground.CGColor);
        CGContextFillRect(context, self.bounds);
        CGContextRestoreGState(context);
        
        NSLog(@"Color Exist touches moved");
    }

    if(self.backgroundImage){
        NSLog(@"background image Exist touches moved");
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.backgroundImage.size.height);
        CGContextScaleCTM(context, scale, -scale);
        CGContextDrawImage(context, [self calculateFrameForImage:backgroundImage], self.backgroundImage.CGImage);
        CGContextRestoreGState(context);
    }
    
       
    int i=0;
    for(UIBezierPath * p in paths)
    {
        
       myPath.lineWidth = [[sizes objectAtIndex:i]floatValue];
      [[colors objectAtIndex:i]setStroke];
      [p stroke];
      i++;
    }
    if(touchesCount==1)
    {
        [myPath addLineToPoint:[mytouch locationInView:self]];
        myPath.lineWidth=brushSize;
        [strokeColor setStroke];
        [myPath stroke];
    }

    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self registerValues];
        
}

-(void)setBrushStrokeColor:(UIColor *)_strokeColor{
    [self registerValues];
    self.strokeColor=_strokeColor;
}


-(void) setColorOfBackground:(UIColor *)color{
    colorOfBackground = color;
    [self drawImageAndLines];
}

-(void)setSizeOfBrush:(int)_brushSize{
    [self registerValues];
    self.brushSize =_brushSize;
}




-(void) setBackgroundPhotoImage:(UIImage *)image{
    translation =CGPointZero;
    scale =1;
    
    self.backgroundImage = image;
    //self.colorOfBackground = nil;
    self.backgroundScreen = nil;
    [self drawImageAndLines];
}

-(void) setScreenshotAsBackgroundPhotoImage:(UIImage *)image{
    translation =CGPointZero;
    scale =1;
    
    self.backgroundImage = nil;
    self.colorOfBackground =nil;
    self.backgroundScreen = image;
    [self drawImageAndLines];
    
    
}


-(void) removeBackgroundPhoto{
    translation =CGPointZero;
    scale =1;

    self.backgroundImage = nil;
    [self drawImageAndLines];

}






@end
