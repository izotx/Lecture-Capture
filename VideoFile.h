//
//  VideoFile.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slide;

@interface VideoFile : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Slide *slide;

@end
