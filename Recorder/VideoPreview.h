//
//  VideoPreview.h
//  Lecture Capture
//
//  Created by DJMobile INC on 11/1/12.
//
//

#import <Foundation/Foundation.h>

@interface VideoPreview : UIView
@property BOOL fullScreen;

@property(nonatomic,strong) UIImageView * previewImageView;
@property  (nonatomic,assign)  id  target;
@property int width;
@property int height;

-(CGRect )adjustToFullScreen:(BOOL)_fullScreen;

@end
