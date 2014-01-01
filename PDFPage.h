//
//  PDFPage.h
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PDF;

@interface PDFPage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * pagenr;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) PDF *pdf;

@end
