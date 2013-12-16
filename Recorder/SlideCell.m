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

-(void)configureWithSlide:(Slide  *)slide;{
    self.slidePreviewImage.image = [UIImage imageWithData:slide.thumbnail];
    self.slideDurationLabel.text=  [NSString stringWithFormat:@"%@", slide.duration];
    self.opaque = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    if([slide.selected  isEqual:@1]){
        self.backgroundColor = [UIColor purpleColor];
    }
    else{
        self.backgroundColor = [UIColor blueColor];
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
