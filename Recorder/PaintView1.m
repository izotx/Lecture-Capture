//
//  PaintView1.m
//  Screen Capture
//
//  Created by Janusz Chudzynski on 8/7/12.
//
//

#import "PaintView1.h"

@implementation PaintView1

NSMutableArray * paths;
NSMutableArray * colors;
NSMutableArray * sizes;

int brushSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor=[UIColor whiteColor];
        self.userInteractionEnabled=YES;
        
        brushSize=10;
        
        myPath=[[UIBezierPath alloc]init];
        myPath.lineCapStyle=kCGLineCapRound;
        myPath.miterLimit=0;
        myPath.lineWidth=brushSize;
        brushPattern=[UIColor redColor];
        
        colors= [[NSMutableArray alloc]initWithCapacity:0];
        paths= [[NSMutableArray alloc]initWithCapacity:0];
        sizes = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}


-(void)setStrokeColor:(UIColor *)color{
    
    [self registerValues];
    if(brushPattern==[UIColor redColor])
    {
        brushPattern=[UIColor greenColor];
    }
    else{
        brushPattern=[UIColor redColor];
    }
    
    brushSize=arc4random()%100;
    
}



-(void)registerValues{
    [paths addObject:myPath];
    NSValue * sizeVal = [NSNumber numberWithFloat:brushSize];
    [sizes addObject:sizeVal];
    [colors addObject:brushPattern];
    
}



#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    myPath= [UIBezierPath bezierPath ];//[[UIBezierPath alloc]init];
    myPath.lineCapStyle=kCGLineCapRound;
    myPath.miterLimit=0;
    myPath.lineWidth=brushSize;
    [myPath moveToPoint:[mytouch locationInView:self]];
    
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UIGraphicsBeginImageContext(self.frame.size);
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    
    int i=0;
    for(UIBezierPath * p in paths)
    {
        
        myPath.lineWidth = [[sizes objectAtIndex:i]floatValue];
        
        [[colors objectAtIndex:i]setStroke];
        [p strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
        i++;
    }
    
    
    [myPath addLineToPoint:[mytouch locationInView:self]];
    myPath.lineWidth=brushSize;
    [brushPattern setStroke];
    [myPath stroke];
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self registerValues];
    
}
@end
