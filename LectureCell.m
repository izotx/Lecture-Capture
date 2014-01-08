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
#import "Manager.h"
#import "LectureAPI.h"

@interface LectureCell()
@property (nonatomic,strong) Lecture * lecture;
@end

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
    // NSDictionary *ob = @{@"object":object,@"super":self};

    
    Lecture * lecture = (Lecture *)[object objectForKey:@"object"];
    self.lecture = lecture;
   // id vc =[object objectForKey:@"super"];
    self.titleLabel.text = lecture.name;
    self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@",lecture.duration];
    
     self.slidesLabel.text = [NSString stringWithFormat:@"%d slides",lecture.slides.count];
    
    float k = lecture.video.length/(1024 * 1024);
    
    self.fileSizeLabel.text=[NSString stringWithFormat:@"%.1f MB",k ];
  
    _ctb.indexPath = indexPath;
    [_ctb addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
   }
-(void)uploadButtonPressed:(id)sender{
    if([[Manager sharedInstance]userId]){
        [LectureAPI uploadLecture:self.lecture];
    }
    else{
        UIAlertView * a = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Log In to upload the recording." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }

}


@end
