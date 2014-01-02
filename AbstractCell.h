//
//  AbstractCell.h
//  Lecture Capture
//
//  Created by sadmin on 1/1/14.
//
//

#import <UIKit/UIKit.h>

@interface AbstractCell : UITableViewCell
-(void)configureCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
@end
