//
//  PDFCell.m
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import "PDFCell.h"
#import "PDF.h"

@implementation PDFCell

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
    /// NSDictionary *ob = @{@"object":object,@"super":self};

    PDF * pdf = (PDF *) [object objectForKey:@"object"];
    self.pdfTitle.text = pdf.filename;
    self.numberOfPages.text= [NSString  stringWithFormat:@"%d pages", pdf.page.count];
    self.pdfSize.text =   [NSString  stringWithFormat:@"%d pages", pdf.page.count];
    
    
}

@end
