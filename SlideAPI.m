//
//  SlideAPI.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/22/13.
//
//

#import "SlideAPI.h"
#import "AppDelegate.h"
#import "Slide.h"

@interface SlideAPI()

@end

@implementation SlideAPI
-(instancetype) init{
    if(self =[super init]){
        _audioPieces = [NSMutableArray new];
        _moviePieces =[NSMutableArray new];
    }
    return self;
}


+(void)save;{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        
    }
}

+(void)resetSlide:(Slide *)slide;{
    [slide removeAudioFiles:slide.audioFiles];
    [slide removeVideoFiles:slide.videoFiles];
    slide.audio = nil;
    slide.video = nil;
    slide.duration =@0;
    slide.size=@0;
    slide.thumbnail = nil;
    slide.modifiedimage = nil;
}

@end
