//
//  AudioRecorder.h
//  Recorder
//
//  Created by DJMobile INC on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorder : NSObject<AVAudioRecorderDelegate>
{
    NSString *  recorderFilePath;
}
@property(nonatomic, retain) NSString *  recorderFilePath;
@property BOOL ready;
- (void) startRecording;
- (void) stopRecording;

@end
