//
//  Slide+Operations.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "Slide+Operations.h"
@interface Slide()
@property(nonatomic, strong) NSMutableArray * audioPieces;
@property(nonatomic, strong) NSMutableArray * moviePieces;


@end
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
    if(!self.moviePieces){
        self.moviePieces = [NSMutableArray new];
    }
    [self.moviePieces addObject:file];
}

-(void)addAudioPiece:(NSString *)file{
    if(!self.audioPieces){
        self.audioPieces = [NSMutableArray new];
    }
    [self.audioPieces addObject:file];
}

-(NSMutableArray *)getAudio;{

    return self.audioPieces;
}
-(NSMutableArray *)getVideo;{
    
    return self.moviePieces;
}


@end
