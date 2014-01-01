//  PDFCell.m
//  Lecture Capture
//  Created by sadmin on 12/23/13

#import "PDFCell.h"

@implementation PDFCell


-(void)configureCell:(id)object{
    [self configureWithObject:object];
}

-(void)configureWithObject:(PDFPage *)page;{
    if(!page.thumb){
    
    }
    self.thumbnail.image = [UIImage imageWithData:page.thumb];
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
