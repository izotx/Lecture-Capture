//
//  PDF.h
//  Lecture Capture
//
//  Created by sadmin on 12/23/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PDFPage;

@interface PDF : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSSet *page;
@end

@interface PDF (CoreDataGeneratedAccessors)

- (void)addPageObject:(PDFPage *)value;
- (void)removePageObject:(PDFPage *)value;
- (void)addPage:(NSSet *)values;
- (void)removePage:(NSSet *)values;

@end
