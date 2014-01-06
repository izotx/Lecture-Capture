//
//  VideoFile.h
//  Lecture Capture
//
//  Created by sadmin on 1/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Slide;

@interface VideoFile : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Slide *slide;

@end
