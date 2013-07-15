//
//  PaintView.m
//  CoreImageisFun
//
//  Created by Janusz Chudzynski on 8/6/12.
//  Copyright (c) 2012 Janusz Chudzynski. All rights reserved.
//
//#import "AVCaptureHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "PaintView.h"

@implementation PaintView
@synthesize colorOfBackground,strokeColor;
@synthesize brushSize;
@synthesize backgroundImage, startImage;
@synthesize myPath;

@synthesize panGesture;
@synthesize pinchGesture; 
@synthesize backgroundScreen;

@synthesize eraseMode;

NSMutableArray * paths;
NSMutableArray * colors;
NSMutableArray * sizes;
NSMutableArray * backgroundColors;
NSMutableArray * backgroundImages;

UIBezierPath * eraserPath;
float scale;
CGPoint translation;

NSMutableDictionary * redo;
CGLayerRef destLayer;
CGContextRef destContext;
CGMutablePathRef realPath;
BOOL layerReady;


- (id)initWithFrame:(CGRect)frame
{
    translation = CGPointZero;

    
    NSMutableArray * p = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray * c = [[NSMutableArray alloc]initWithCapacity:1];
    NSMutableArray * s = [[NSMutableArray alloc]initWithCapacity:0];
    
    redo = [[NSMutableDictionary alloc]initWithCapacity:0];
    [redo setValue:p forKey:@"paths"];
    [redo setValue:c forKey:@"colors"];
    [redo setValue:s forKey:@"sizes"];
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

         UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, YES);
        
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        startImage =self.image;
        UIGraphicsEndImageContext();

        self.backgroundColor=[UIColor whiteColor];
        self.userInteractionEnabled=YES;
        
        brushSize=10;
        UIBezierPath * path= [UIBezierPath bezierPath];
        eraserPath = [UIBezierPath bezierPath];
        
        self.myPath = path;
    
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=brushSize;
        strokeColor=[UIColor redColor];
        
        colors= [[NSMutableArray alloc]initWithCapacity:0];
        paths= [[NSMutableArray alloc]initWithCapacity:0];
        sizes = [[NSMutableArray alloc]initWithCapacity:0];
       backgroundColors = [[NSMutableArray alloc]initWithCapacity:0];
       backgroundImages = [[NSMutableArray alloc]initWithCapacity:0];
      
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
        
        CGFloat contentScale = [[UIScreen mainScreen]scale];
        CGSize layerSize = CGSizeMake(self.bounds.size.width * contentScale,self.bounds.size.height * contentScale);
        destLayer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), layerSize, NULL);
        destContext = CGLayerGetContext(destLayer);
        CGContextScaleCTM(destContext, contentScale, contentScale);
        layerReady = NO;

        
        
    }
    return self;
}

-(void)panMethod:(UIPanGestureRecognizer * )gesture{
    translation = [gesture translationInView:self] ;
    [self drawImageAndLines];
}

-(void)pinchMethod:(UIPinchGestureRecognizer * )pr{
    scale = pr.scale;
    [self drawImageAndLines];
}

-(void)undo{
    NSMutableArray * p = [redo objectForKey:@"paths"];
    NSMutableArray * c = [redo objectForKey:@"colors"];
    NSMutableArray * s = [redo objectForKey:@"sizes"];
    
    [p addObject:paths];
    [c addObject:colors];
    [s addObject:sizes];
    
    [colors removeLastObject];
    [paths removeLastObject];
    [sizes removeLastObject];
    
    [redo setValue:p forKey:@"paths"];
    [redo setValue:c forKey:@"colors"];
    [redo setValue:s forKey:@"sizes"];
        
    [self drawImageAndLines];
}

-(void)redo{
    
    NSMutableArray * p = [redo objectForKey:@"paths"];
    NSMutableArray * c = [redo objectForKey:@"colors"];
    NSMutableArray * s = [redo objectForKey:@"sizes"];
    if(p.count >0){
        p = [p objectAtIndex:0];
        c = [c objectAtIndex:0];
        s = [s objectAtIndex:0];
        paths = p;
        colors= c;
        sizes = s;
        
        [self drawImageAndLines];
    }
}


-(void)drawImageAndLines{

    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, YES);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
  
    if(self.colorOfBackground)
    {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, colorOfBackground.CGColor);
        CGContextFillRect(context, self.bounds);
        CGContextRestoreGState(context);
    }

    if(self.backgroundImage)
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0f, self.backgroundImage.size.height);
        CGContextScaleCTM(context, scale, -scale);
        CGRect frame = [self calculateFrameForImage:backgroundImage];
        NSLog(@" ");
        
        CGContextDrawImage(context, frame, self.backgroundImage.CGImage);
       
        CGContextStrokePath(context);
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
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = image;
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

   CGRect frame = CGRectMake(((selfFrameWidth - imageWidth)/2.0 + translation.x ) / scale, 0-translation.y/ scale, imageWidth, imageHeight);
    
    return frame;
}

-(void)eraseContext{
    
     UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, YES);
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
  //  int touchesCount=    [[event allTouches]count];
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
       
    @autoreleasepool {
        UIBezierPath * path= [UIBezierPath bezierPath];
        self.myPath = path;
        eraserPath = [UIBezierPath bezierPath];
    }
    realPath = CGPathCreateMutable();
    CGPoint point =  [mytouch locationInView:self];
    CGPathMoveToPoint(realPath, &CGAffineTransformIdentity, point.x, point.y);
    
    [eraserPath moveToPoint:[mytouch locationInView:self]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
       
    int touchesCount=    [[event allTouches]count];
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, YES);
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    
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
        CGRect  rect = [self calculateFrameForImage:backgroundImage];
        
        NSLog(@" %f %f %f %f ",rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
        
        
        CGContextDrawImage(context, [self calculateFrameForImage:backgroundImage], self.backgroundImage.CGImage);
        CGContextRestoreGState(context);
    }
    if(eraseMode == YES)
    {
        [self erasePathAtPoint:[mytouch locationInView:self]];
        [eraserPath addLineToPoint:[mytouch locationInView:self]];
    }
    else{
        if(touchesCount==1)
        {
        //[myPath addLineToPoint:[mytouch locationInView:self]];
        // myPath.lineWidth=brushSize;
        //[strokeColor setStroke];
        //[myPath stroke];
            CGContextSaveGState(context);
          //   CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
            //CGContextScaleCTM(context, scale, -scale);
           // CGContextDrawImage(context,self.bounds, self.image.CGImage);
            
            
            
            CGContextRestoreGState(context);
            [self.image drawInRect:self.bounds];
            
            CGPoint point = [mytouch locationInView:self];
            CGPathAddLineToPoint(realPath, &CGAffineTransformIdentity, point.x, point.y);
            CGContextSetLineWidth(context, self.brushSize);
            CGContextAddPath(context, realPath);
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
            CGContextSetFillColorWithColor(context, strokeColor.CGColor);
            CGContextStrokePath(context);
            
        }

      

    }

    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // [self registerValues];
        
}

-(void)setBrushStrokeColor:(UIColor *)_strokeColor{
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

//called when user updates background of the recording
-(void) setBackgroundPhotoImage:(UIImage *)image{
    translation =CGPointZero;
    scale =1;
    self.backgroundImage = image;
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

-(void)erasePathAtPoint:(CGPoint)point{

    int counter =0;
    for(UIBezierPath * p in paths)
    {
        //get poins from the path
        CGPathRef cp = p.CGPath;
        CGRect r = CGPathGetBoundingBox(cp);
        //Delete path p from collection
        CGRect r1 = CGPathGetBoundingBox(eraserPath.CGPath);
        @try {
            if(CGRectContainsPoint(r, point))
            {
                [paths removeObject:p];
                [colors removeObjectAtIndex:counter];
                [sizes removeObjectAtIndex:counter];
                NSLog(@"1");
                break;
            }
            else if(CGRectIntersectsRect(r, r1))
            {
                NSLog(@"2");
                [paths removeObject:p];
                [colors removeObjectAtIndex:counter];
                [sizes removeObjectAtIndex:counter];

                break;
            }
            counter ++;
 
        }
        @catch (NSException *exception) {
            NSLog(@"Exception : %@ ",[exception debugDescription]);
        }
        @finally {
             NSLog(@"Erase Finally" );
           // break;
        }
    }
    [self drawImageAndLines];
}

@end
