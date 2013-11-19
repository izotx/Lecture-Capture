//
//  Slide+Operations.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "Slide+Operations.h"

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

@end
