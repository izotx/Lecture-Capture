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
+ (id)createLectureWithName:(NSString *)name;
+ (id)removeLecture:(Lecture*)lecture;
+ (id)saveLecture:(Lecture*)lecture;
+ (id)compile;
+ (Slide *)addNewSlideToLecture:(Lecture *)lecture afterSlide:(Slide*)slide;
+(void)saveLecturetoLibrary: (Lecture *)lecture;
+(void)uploadLecture: (Lecture *)lecture;


@end
