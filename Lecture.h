//
//  Lecture.h
//  Lecture Capture
//
//  Created by sadmin on 1/2/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slide;

@interface Lecture : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * lecture_description;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSData * video;
@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) NSSet *slides;
@end

@interface Lecture (CoreDataGeneratedAccessors)

- (void)addSlidesObject:(Slide *)value;
- (void)removeSlidesObject:(Slide *)value;
- (void)addSlides:(NSSet *)values;
- (void)removeSlides:(NSSet *)values;

@end
