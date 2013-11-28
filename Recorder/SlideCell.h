//
//  SlideCell.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/20/13.
//
//

#import <UIKit/UIKit.h>
@class Slide;

@interface SlideCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *slidePreviewImage;
@property (strong, nonatomic) IBOutlet UILabel *slideDurationLabel;
-(void)configureWithSlide:(Slide  *)slide;

@end