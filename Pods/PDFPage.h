//
//  PDFPage.h
//  Pods
//
//  Created by sadmin on 1/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PDF;

@interface PDFPage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * pagenr;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSString * pdfid;
@property (nonatomic, retain) PDF *pdf;

@end
