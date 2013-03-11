//
//  VideoPreview.m
//  Lecture Capture
//
//  Created by sadmin on 11/1/12.
//
//

#import "VideoPreview.h"

@implementation VideoPreview
@synthesize fullScreen;
@synthesize previewImageView;
@synthesize target;
@synthesize width;
@synthesize height;

UIToolbar * toolBar;
int smallWidth = 300;
int smallHeight = 344;


-(id)initWithFrame:(CGRect)_frame{
    self = [super initWithFrame:_frame];
    if(self)
    {
        fullScreen = false;
        self.frame = CGRectMake(0, 0, smallWidth, smallHeight);
        [self configureView];
        [self adjustToFullScreen:fullScreen];
    }
    return self;
}


-(void)configureView{
   
    width = self.frame.size.width;
    height = self.frame.size.height;
   
    toolBar = [[UIToolbar alloc]init];
    UIBarButtonItem * resize = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"resizeBtn"] style:UIBarButtonItemStylePlain target:self.target action:@selector(resizeMe)];
    UIBarButtonItem * switchCamera = [[UIBarButtonItem alloc]initWithTitle:@"Switch" style:UIBarButtonItemStyleBordered target:self.target action:@selector(switchCamera)];
    
    UIBarButtonItem * dismiss = [[UIBarButtonItem alloc]initWithTitle:@"Dismiss" style:UIBarButtonItemStyleBordered target:self.target action:@selector(dismiss)];
    UIBarButtonItem * flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray * items = [NSArray arrayWithObjects:resize,flex,switchCamera, dismiss, nil];
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar setItems:items];
    previewImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:toolBar];
    [self addSubview:previewImageView];
}

-(CGRect )adjustToFullScreen:(BOOL)_fullScreen{

    self.fullScreen= _fullScreen;
    if(fullScreen)
    {
        self.frame = CGRectMake(0,0,width,height);
        self.bounds =CGRectMake(0,0,width,height);
        toolBar.frame = CGRectMake(0,height-44,width,44);
        float l = 0.9 * (height -44);
        float x = (width - l)/2.0;
        float tempWidth = 0.8 * width;
        x = (width-tempWidth) /2.0;
        float y = (height - 44- l)/2.0;
        previewImageView.frame = CGRectMake(x, y, tempWidth, l);
        
    
    }
    else{
        self.frame = CGRectMake(0, 0, smallWidth,smallHeight);
        self.bounds = CGRectMake(0, 0, smallWidth,smallHeight);
     
        toolBar.frame = CGRectMake(0,smallHeight-44,smallWidth,44);
        float l = 0.9 * (smallHeight -44);
        float x = (smallWidth - l)/2.0;
        float y = (smallWidth - l)/2.0;
        previewImageView.frame = CGRectMake(x, y, l, l);
    }

    return previewImageView.frame;
}


@end
