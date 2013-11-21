//
//  Slide.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lecture;

@interface Slide : NSManagedObject

@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSData * video;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) Lecture *lecture;

@end
