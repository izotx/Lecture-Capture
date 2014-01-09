//
//  PaintView.m
//  CoreImageisFun
//
//  Created by DJMobile INC on 8/6/12.
//  Copyright (c) 2012 DJMobile INC. All rights reserved.
//
//#import "AVCaptureHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "PaintView.h"
#import "PDFParser.h"
#import  "PDFPageRenderer.h"
@interface PaintView()
    @property CGPDFPageRef pdfpage;
@end

@implementation PaintView {
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
	BOOL layerReady;
    PDFParser * parser;
    UIImageView *currentPathImageView;
    CGPDFDocumentRef document;
   
    
}
@synthesize colorOfBackground,strokeColor;
@synthesize brushSize;
@synthesize backgroundImage, startImage;
@synthesize myPath;

@synthesize panGesture;
@synthesize pinchGesture;
//@synthesize backgroundScreen;
@synthesize eraseMode;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        translation = CGPointZero;
      //  NSString * filepath =[NSString pathWithComponents:@[DOCUMENTS_FOLDER,@"Inbox",@"canon.pdf"]];
      //  NSLog(@"%@",filepath);

        if(!parser){
        //    parser = [[PDFParser alloc]initWithFilePath:filepath];
        }
        //document = [parser CreatePDFDocumentRef:filepath];
        
        NSMutableArray * p = [NSMutableArray new];
        NSMutableArray * c = [NSMutableArray new];
        NSMutableArray * s = [NSMutableArray new];
        
        redo = [NSMutableDictionary new];
        
        [redo setValue:p forKey:@"paths"];
        [redo setValue:c forKey:@"colors"];
        [redo setValue:s forKey:@"sizes"];
        
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
        
        // This image view will only be used while touches are coming in.
        // Once the touches end, it will be cleared and its content collapsed
        // into the main image.
        currentPathImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		currentPathImageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self addSubview:currentPathImageView];
        
    }
    return self;
}

-(void)panMethod:(UIPanGestureRecognizer * )gesture{
    translation = [gesture translationInView:self] ;
    NSLog(@"%f %f",translation.x,translation.y);
    
    [self drawImageAndLines];
}

-(void)pinchMethod:(UIPinchGestureRecognizer * )gesture{
    
// [self adjustAnchorPointForGestureRecognizer:gesture];
//    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
//       // [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
//       // scale += gesture.scale;
//        
//       // [gesture setScale:1];
//    }
//    scale +=0.01;
//    NSLog(@"%f",scale);
    if(scale<2 &&scale>0.3){
        scale =gesture.scale;
    }
    
    
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


-(void)drawImageAndLines {
   
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1);
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
        //CGContextTranslateCTM(context, 0.0f, self.backgroundImage.size.height);
        //CGContextScaleCTM(context, scale, -scale);
       // CGContextScaleCTM(context, 0.6, 0.6);
        CGRect r = [self calculateFrameForImage:backgroundImage];
        [backgroundImage drawInRect:r];
        
        //CGContextDrawImage(context, r, self.backgroundImage.CGImage);

        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    
      //  self.pdfpage =   [parser getPage:6 inDocument:document];
      //  [PDFPageRenderer renderPage:self.pdfpage inContext:context];
    
    }
    int i=0;
    
    for(UIBezierPath * p in paths)
    {
        [[colors objectAtIndex:i] setStroke];
        [p stroke];
        
        i++;
    }
	
    if (myPath) {
        [strokeColor setStroke];
        myPath.lineWidth = brushSize;
        [myPath stroke];
    }
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawCurrentPath
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1);
    
    if (myPath) {
        [strokeColor setStroke];
        myPath.lineWidth = brushSize;
        [myPath stroke];
    }
    
    UIImage *currentPathImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    currentPathImageView.image = currentPathImage;
}

- (void)clearCurrentPathDrawing
{
    currentPathImageView.image = nil;
}


-(void)registerValues{
    if (myPath) {
        [paths addObject:myPath];
    }
    NSValue * sizeVal = [NSNumber numberWithFloat:brushSize];
    [sizes addObject:sizeVal];
    [colors addObject:strokeColor];
}


-(CGRect ) calculateFrameForImage:(UIImage *)image
{
    float imageWidth = image.size.width * scale ;
    float imageHeight = image.size.height* scale;
    
   // float selfFrameWidth = self.frame.size.width;
    
//    CGRect frame = CGRectMake(((selfFrameWidth - imageWidth)/2.0 + translation.x ) / scale, 0-translation.y/ scale, imageWidth, imageHeight);
    
    //center
    float x = CGRectGetMidX(self.bounds)-imageWidth/2.0 + translation.x;
    float y = CGRectGetMidY(self.bounds)-imageHeight/2.0 + translation.y;
    
    CGRect frame =(CGRect){x, y,imageWidth,imageHeight};
    
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
        CGRect r = [self calculateFrameForImage:backgroundImage];
        //CGContextScaleCTM(context, 0.25, 0.25);

        CGContextDrawImage(context, r, self.backgroundImage.CGImage);
        CGContextRestoreGState(context);
        
    }
    else{
        self.image = self.startImage;
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
    
    myPath.lineCapStyle=kCGLineCapRound;
    myPath.lineJoinStyle=kCGLineJoinRound;
    // myPath.miterLimit=15;
    myPath.lineWidth=brushSize;
    [myPath moveToPoint:[mytouch locationInView:self]];
    [eraserPath moveToPoint:[mytouch locationInView:self]];
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    int touchesCount=    [[event allTouches]count];
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
	
    if(eraseMode == YES)
    {
        [self erasePathAtPoint:[mytouch locationInView:self]];
        [eraserPath addLineToPoint:[mytouch locationInView:self]];
    }
    else{
        if(touchesCount==1)
        {
            [myPath addLineToPoint:[mytouch locationInView:self]];
        }
    }
	
	[self drawCurrentPath];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self registerValues];
    self.myPath = nil;
    [self clearCurrentPathDrawing];
    [self drawImageAndLines];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self registerValues];
    self.myPath = nil;
	[self clearCurrentPathDrawing];
    [self drawImageAndLines];
}

-(void)prepareForImageCapture
{
    [self drawImageAndLines];
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
    //calculate scale
    
//    float aspect = image.size.width/image.size.height;
    
    float sx = image.size.width/CGRectGetWidth(self.bounds);
    float sy = image.size.height/CGRectGetHeight(self.bounds);
    //take bigger one
    float _scale = sx>sy?sx:sy;
    if(_scale >1){
        //scale the context down to fit
        scale = 1/sy;
    }
    
    self.backgroundImage = image;
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
              
                break;
            }
            else if(CGRectIntersectsRect(r, r1))
            {
        
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