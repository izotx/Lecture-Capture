//
//  Slide.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Slide : NSManagedObject

@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSData * video;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSManagedObject *lecture;

@end
