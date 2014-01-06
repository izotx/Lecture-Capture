//
//  AudioRecorder.m
//  Recorder
//
//  Created by DJMobile INC on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioRecorder.h"
@interface AudioRecorder()
@property(nonatomic,strong) NSMutableDictionary * recordSetting;
@property(nonatomic,strong) AVAudioRecorder * recorder;
@property(nonatomic,strong)  AVAudioSession *audioSession;
@end

@implementation AudioRecorder
@synthesize recorderFilePath;

-(instancetype)init{

    if(self){
        _audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [_audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
           
        }
        [_audioSession setActive:YES error:&err];
        err = nil;
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
           
        }
        // Different Settings for Recording
        _recordSetting = [[NSMutableDictionary alloc] init];
        
        [_recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [_recordSetting setValue:[NSNumber numberWithFloat:32000.0] forKey:AVSampleRateKey];
        [_recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        
        BOOL audioHWAvailable = false;
        
        if([_audioSession respondsToSelector:@selector(isInputAvailable)])
        {
            audioHWAvailable = _audioSession.inputAvailable;
            self.ready = YES;
        }
        
        
        
        if (! audioHWAvailable) {
            UIAlertView *cantRecordAlert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: @"Audio input hardware not available"
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [cantRecordAlert show];
            self.ready = NO;
            
        }

        
        
        
    }
    return self;
}

- (void) startRecording{
    self.ready = NO;
    self.completed = NO;
    self.isRecording = YES;
    
    //File Path
    int random = arc4random()%100 * arc4random();
    self.recorderFilePath = [NSString stringWithFormat:@"%@/%@%d.caf", DOCUMENTS_FOLDER,@"audio_piece",random];
    
    NSURL *url = [NSURL fileURLWithPath:self.recorderFilePath];
    NSError * err = nil;
    _recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:_recordSetting error:&err];
    if(!_recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [_recorder setDelegate:self];
    //[recorder prepareToRecord];
    _recorder.meteringEnabled = YES;

    [_recorder record];
}

- (void) stopRecording{
    [_recorder stop];
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully: %d",flag);

    self.ready = YES;
    self.completed = YES;
    self.isRecording = NO;
    self.recorderFilePath = nil;
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    
}

-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    self.isRecording = NO;
}



@end
