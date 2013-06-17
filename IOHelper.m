//
//  IOHelper.m
//  Lecture Capture


#import "IOHelper.h"

@implementation IOHelper


#pragma mark COMBINING FILES
//Put Together
-(void)putTogetherVideo:(NSArray *)videoPieces andAudioPieces:(NSArray *)audioPieces andCompletionBlock:(CompletionBlock)block saveAtPath:(NSString *)path
{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack =[[AVMutableCompositionTrack alloc]init];
    AVMutableCompositionTrack *audioCompositionTrack =[[AVMutableCompositionTrack alloc]init];
    videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError * error;
    for(int i=0;i<videoPieces.count;i++)
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * movieFilePath;
        NSString * audioFilePath;
        movieFilePath = [videoPieces objectAtIndex:i];
        audioFilePath = [audioPieces objectAtIndex:i];
        
        
        if(![fm fileExistsAtPath:movieFilePath]){
            NSLog(@"Movie doesn't exist %@ ",movieFilePath);
        }
        else{
            NSLog(@"Movie exist %@ ",movieFilePath);
        }
        
        if(![fm fileExistsAtPath:audioFilePath]){
            NSLog(@"Audio doesn't exist %@ ",audioFilePath);
        }
        else{
            NSLog(@"Audio exists %@ ",audioFilePath);
        }
        
        
        NSURL *videoUrl = [NSURL fileURLWithPath:movieFilePath];
        NSURL *audioUrl = [NSURL fileURLWithPath:audioFilePath];
        
        
        AVURLAsset *videoasset = [[AVURLAsset alloc]initWithURL:videoUrl options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
        AVAssetTrack *videoAssetTrack= [[videoasset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        
        AVURLAsset *audioasset = [[AVURLAsset alloc]initWithURL:audioUrl options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
        AVAssetTrack *audioAssetTrack= [[audioasset tracksWithMediaType:AVMediaTypeAudio] lastObject];
        
        CMTime tempDuration = mixComposition.duration;
        
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset.duration) ofTrack:audioAssetTrack atTime:tempDuration error:&error];
        
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoasset.duration) ofTrack:videoAssetTrack atTime:tempDuration error:&error];
        
        if(error)
        {
            NSLog(@"Ups. Something went wrong! %@", [error debugDescription]);
        }
    }
    
    NSURL * movieURL = [NSURL fileURLWithPath:path];
   
    
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    exporter.outputURL=movieURL;
    exporter.shouldOptimizeForNetworkUse=YES;
    
    CMTimeValue val = mixComposition.duration.value;
    
    CMTime start=CMTimeMake(0, 600);
    CMTime duration=CMTimeMake(val, 600);
    CMTimeRange range=CMTimeRangeMake(start, duration);
    exporter.timeRange=range;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch ([exporter status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Export failed: %@ %@", [[exporter error] localizedDescription],[[exporter error]debugDescription]);
                block(false,CMTimeMake(0,30));
                break;
            }
            case AVAssetExportSessionStatusCancelled:{ NSLog(@"Export canceled");
                block(false,CMTimeMake(0,30));
                break;}
            case AVAssetExportSessionStatusCompleted:
            {
                CMTime duration = mixComposition.duration;
                block(true,duration);
                [self cleanFiles:audioPieces];
                [self cleanFiles:videoPieces];
                 
            }
        }}];
}


//self clean files
-(void)cleanFiles:(NSArray *)files{
    NSFileManager * fm = [NSFileManager  defaultManager];
    NSError * error = nil;
    for(NSString * path in files){
        [fm removeItemAtPath:path error:&error];
    }
    if(error){
        NSLog(@"Error While deleting file pieces: %@",[error debugDescription]);
    }
    
}

-(NSString*)getRandomFilePath{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    
    float ran = arc4random()%100;
    NSString * pathToSave = [NSString stringWithFormat:@"Output_Date:%@_%f.mov",caldate,ran];
    
    pathToSave =[DOCUMENTS_FOLDER stringByAppendingPathComponent:pathToSave];
    return pathToSave;
}


@end
