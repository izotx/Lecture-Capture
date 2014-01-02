//  PDFCell.m
//  Lecture Capture
//  Created by sadmin on 12/23/13

#import "PDFPageCell.h"

@implementation PDFPageCell


-(void)configureCellWithObject:(id)object{
    NSIndexPath * _indexPath;
    _indexPath = [(NSDictionary  *)object objectForKey:@"indexpath"];
    id pdfpage =[(NSDictionary  *)object objectForKey:@"object"];
    assert([pdfpage isKindOfClass:[PDFPage class]]);
    self.thumbnail.image = [UIImage imageWithData:[(PDFPage *)pdfpage thumb]];
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
