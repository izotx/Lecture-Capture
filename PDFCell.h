//
//  PDFCell.h
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import <UIKit/UIKit.h>

@interface PDFCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *pdfTitle;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPages;
@property (strong, nonatomic) IBOutlet UILabel *pdfSize;

-(void)configureCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end