//
//  LectureCell.m
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import "LectureCell.h"
#import "Lecture.h"
#import "CustomTableButton.h"

@implementation LectureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;{
    Lecture * lecture = (Lecture *)object;
    self.titleLabel.text = lecture.name;
    self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@",lecture.duration];
    self.fileSizeLabel.text=[NSString stringWithFormat:@"%@",lecture.size];
  
    _ctb.indexPath = indexPath;
    [_ctb addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

}

@end
