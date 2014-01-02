//
//  LectureCell.h
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import <UIKit/UIKit.h>
@class CustomTableButton;

@interface LectureCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UILabel * titleLabel;
@property(nonatomic,strong) IBOutlet UILabel * durationLabel;
@property(nonatomic,strong) IBOutlet UILabel * fileSizeLabel;
@property(nonatomic,strong) IBOutlet CustomTableButton * ctb;

-(void)configureCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;


@end
