//
//  IOHelper.m
//  Lecture Capture


#import "IOHelper.h"
#import "AudioFile.h"
#import "VideoFile.h"
#import "Slide.h"

@implementation IOHelper

#warning add NSOPerationQueue

#pragma mark COMBINING FILES
//Put Together
-(void)putTogetherVideo:(NSArray *)videoPieces andAudioPieces:(NSArray *)audioPieces andCompletionBlock:(CompletionBlock)block forSlide:(Slide *)slide saveAtPath:(NSString *)path
{
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack;// =[[AVMutableCompositionTrack alloc]init];
    AVMutableCompositionTrack *audioCompositionTrack;// =[[AVMutableCompositionTrack alloc]init];
    videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError * error;
    for(int i=0;i<videoPieces.count;i++)
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * movieFilePath;
        NSString * audioFilePath;
        movieFilePath = [(VideoFile *) [videoPieces objectAtIndex:i] path];
        audioFilePath = [(AudioFile *) [audioPieces objectAtIndex:i] path];
        
        if(![fm fileExistsAtPath:movieFilePath]){
            NSLog(@"Movie doesn't exist %@ ",movieFilePath);
        }
        else{
           NSLog(@"Audio exists %@ ",movieFilePath);
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
            NSLog(@"Ups. Something went wrong! %@ video %f audio %f ", [error debugDescription], CMTimeGetSeconds(videoasset.duration), CMTimeGetSeconds(audioasset.duration));
        }
    }
    
    NSURL * movieURL = [NSURL fileURLWithPath:path];
   
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    exporter.outputURL=movieURL;
    exporter.shouldOptimizeForNetworkUse=YES;
    
    CMTimeValue val = mixComposition.duration.value;
   // NSLog(@"Seconds %f",CMTimeGetSeconds(mixComposition.duration));

    CMTime start=CMTimeMake(0, 600);
    CMTime duration=CMTimeMake(val, 600);
    CMTimeRange range=CMTimeRangeMake(start, duration);
    exporter.timeRange=range;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch ([exporter status]) {
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"Export failed: %@ %@", [[exporter error] localizedDescription],[[exporter error]debugDescription]);
                block(false,CMTimeMake(0,30),slide,path);
                break;
            }
            case AVAssetExportSessionStatusCancelled:{ NSLog(@"Export canceled");
                block(false,CMTimeMake(0,30),slide,path);
                break;}
            case AVAssetExportSessionStatusCompleted:
            {
                slide.video = [NSData dataWithContentsOfURL:movieURL];
                slide.url = path;

                block(true,duration,slide,path);
                NSLog(@"Seconds %f",CMTimeGetSeconds(duration));
                
            }
        }}];
}


//self clean files
-(void)cleanFiles:(NSArray *)files{
    NSFileManager * fm = [NSFileManager  defaultManager];
    NSError * error = nil;
    
    for(NSManagedObject * file in files){
        
        if([file isKindOfClass:[AudioFile class]]){
           AudioFile * afile = (AudioFile *)file;
            //[fm removeItemAtPath:afile.path error:&error];
        }
        if([file isKindOfClass:[VideoFile class]]){
            AudioFile * vfile = (AudioFile *)file;
           // [fm removeItemAtPath:vfile.path error:&error];
        }
       
    }
    if(error){
        NSLog(@"Error While deleting file pieces: %@",[error debugDescription]);
    }
}





+(NSString*)getRandomFilePath{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    
    float ran = arc4random()%100;
    NSString * pathToSave = [NSString stringWithFormat:@"Output_Date:%@_%f.mov",caldate,ran];
    
    pathToSave =[DOCUMENTS_FOLDER stringByAppendingPathComponent:pathToSave];
    return pathToSave;
}

-(void)deletePath:(NSString *)path{
NSFileManager * fm = [NSFileManager defaultManager];
NSError * error;
if( [fm fileExistsAtPath:path])
{
    [fm removeItemAtPath:path error:&error];
}
if(error)
{
    NSLog(@"Error %@ ",[error debugDescription]);
}
else{
    NSLog(@"File %@ deleted",path);
}
}


-(void)saveToLibraryFileAtPath:(NSString*)videoPath;{
    if(videoPath.length>0)
    {
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
    }
    else
    {
        NSString * message=@"You need to select a movie from the list.";
        UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [al show];
    }
}

- (void)video:(NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString * message;
    if(error)
    {
        NSLog(@"didFinishSavingWithError: %@", error);
        message= [NSString stringWithFormat: @"Error. %@",[error localizedDescription]];
    }
    else{
        message=@"Movie was successfully saved. It can be accessed from Photos App.";
    }
    UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [al show];
    
}



@end
