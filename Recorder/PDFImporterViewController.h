//
//  PDFImporterViewController.h
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.
//
//

#import <UIKit/UIKit.h>
@class PDF;
@interface PDFImporterViewController : UIViewController

-(void)parsePDF:(NSURL *)pdf;
@property (strong,nonatomic) PDF * pdf;
@end
