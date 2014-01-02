//
//  PDFCell.h
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.
//
//

#import <UIKit/UIKit.h>
#import "PDFPage.h"

@interface PDFPageCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UIImageView * thumbnail;

-(void)configureCellWithObject:(id)object;


@end
