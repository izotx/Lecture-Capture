//
//  ScreenView.m
//  Recorder
//
//  Created by Janusz Chudzynski on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScreenView.h"

@implementation ScreenView
@synthesize delegate;
@synthesize image;
@synthesize screen_id;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    if(tapCount==2)
    {
        //Update Screen? How? Delegate...
        [delegate screenshotTapTwice:self.image];
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
