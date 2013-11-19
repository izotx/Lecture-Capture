//
//  LectureAPI.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import <Foundation/Foundation.h>
@class Lecture;

@interface LectureAPI : NSObject
+ (id)createLectureWithName:(NSString *)name;
+ (id)removeLecture:(Lecture*)lecture;
+ (id)saveLecture:(Lecture*)lecture;
+ (id)compile;
//TO DO import pdf



@end
