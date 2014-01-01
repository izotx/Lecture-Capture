//
//  PDFCell.h
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.
//
//

#import <UIKit/UIKit.h>
#import "PDFPage.h"

@interface PDFCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UIImageView * thumbnail;
-(void)configureWithObject:(PDFPage *)page;

@end
