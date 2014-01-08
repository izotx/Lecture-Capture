//
//  SlideCell.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/20/13.
//
//

#import "SlideCell.h"
#import "Slide.h"

@implementation SlideCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)configureCellWithObject:(id)object{
    NSIndexPath * _indexPath;
    _indexPath = [(NSDictionary  *)object objectForKey:@"indexpath"];
    
    assert([[(NSDictionary  *)object objectForKey:@"object"] isKindOfClass:[Slide class]]);
    Slide * slide = [(NSDictionary  *)object objectForKey:@"object"];
    
    self.slidePreviewImage.image = [UIImage imageWithData:slide.thumbnail];
    self.slideDurationLabel.text=  [NSString stringWithFormat:@"%@", slide.duration];
    self.opaque = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.backgroundColor = [UIColor whiteColor];


    if([slide.selected  isEqual:@1]){
        
        self.layer.borderColor = [[UIColor darkGrayColor]CGColor];
        self.layer.borderWidth = 2.0;
    }
    else{
         self.layer.borderWidth = 0.0;
    }
    
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
