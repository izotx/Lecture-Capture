//
//  Slide.h
//  Lecture Capture
//
//  Created by sadmin on 12/2/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AudioFile, Lecture, VideoFile;

@interface Slide : NSManagedObject

@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * video;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSSet *audioFiles;
@property (nonatomic, retain) Lecture *lecture;
@property (nonatomic, retain) NSSet *videoFiles;
@property (nonatomic, strong) NSString * url;
@end

@interface Slide (CoreDataGeneratedAccessors)

- (void)addAudioFilesObject:(AudioFile *)value;
- (void)removeAudioFilesObject:(AudioFile *)value;
- (void)addAudioFiles:(NSSet *)values;
- (void)removeAudioFiles:(NSSet *)values;

- (void)addVideoFilesObject:(VideoFile *)value;
- (void)removeVideoFilesObject:(VideoFile *)value;
- (void)addVideoFiles:(NSSet *)values;
- (void)removeVideoFiles:(NSSet *)values;

@end
