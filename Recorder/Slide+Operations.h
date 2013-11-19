//
//  Slide+Operations.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "Slide.h"

@interface Slide (Operations)
- (void)startRecordingAudio;
- (void)startRecordingVideo;
- (void)changeDisplayTime;
- (void)startRecording;
- (void)duplicateSlide;

@end
