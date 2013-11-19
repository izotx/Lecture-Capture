//
//  Lecture.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slide;

@interface Lecture : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * lecture_description;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSSet *slides;
@end

@interface Lecture (CoreDataGeneratedAccessors)

- (void)addSlidesObject:(Slide *)value;
- (void)removeSlidesObject:(Slide *)value;
- (void)addSlides:(NSSet *)values;
- (void)removeSlides:(NSSet *)values;

@end
