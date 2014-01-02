//
//  AbstractCell.m
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import "AbstractCell.h"

@implementation AbstractCell

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

-(void)configureCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath{

}

@end
