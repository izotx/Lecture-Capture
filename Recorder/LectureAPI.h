//
//  LectureAPI.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import <Foundation/Foundation.h>
@class Lecture;
@class Slide;

@interface LectureAPI : NSObject
- (id)initWithLecture:(Lecture *)lecture;
+ (id)createLectureWithName:(NSString *)name;
+ (id)removeLecture:(Lecture*)lecture;
+ (id)saveLecture:(Lecture*)lecture;
+ (id)compile;
+ (Slide *)addNewSlideToLecture:(Lecture *)lecture afterSlide:(Slide*)slide;

-(id) next;
-(id) previous;

@property(nonatomic,strong) Slide * currentSlide;
@property(nonatomic,strong) Lecture * currentLecture;

@end
