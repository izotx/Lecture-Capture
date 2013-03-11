//
//  ScreenView.h
//  Recorder
//
//  Created by Janusz Chudzynski on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScreenShotDelegate <NSObject>
- (void) screenshotTapTwice:(UIImage *)im;

@end

@interface ScreenView : UIView
@property(nonatomic,assign) id <ScreenShotDelegate>delegate;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,assign) int screen_id;



@end
