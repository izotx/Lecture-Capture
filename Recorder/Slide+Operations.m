//
//  Slide+Operations.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "Slide+Operations.h"
#import "AppDelegate.h"
#import "AudioFile.h"
#import "VideoFile.h"

@implementation Slide (Operations)


- (void)startRecordingAudio;{
    self.video = nil;
}
- (void)startRecordingVideo;{
    self.audio = nil;
}
- (void)changeDisplayTime;{}
- (void)startRecording;{}
- (void)duplicateSlide;{}

-(void)addMoviePiece:(NSString *)file{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    VideoFile * video= [NSEntityDescription insertNewObjectForEntityForName:@"VideoFile" inManagedObjectContext:delegate.managedObjectContext];
    [self addVideoFilesObject:video];
    video.path = file;
    
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        
    }

}

-(void)addAudioPiece:(NSString *)file{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    AudioFile * audio= [NSEntityDescription insertNewObjectForEntityForName:@"AudioFile" inManagedObjectContext:delegate.managedObjectContext];
    [self addAudioFilesObject:audio];
    audio.path = file;
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        
    }

}


@end
