//
//  Lecture+Operations.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "Lecture.h"

@interface Lecture (Operations)
-(id)addSlide;
-(id)removeSlide;
-(id)reorderSlides;

- (id)initLectureWithName:(NSString *)name;

- (void)removeLecture;
- (void)compile;

@end
