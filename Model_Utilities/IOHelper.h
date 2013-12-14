//
//  IOHelper.h
//  Lecture Capture
//
//  Created by DJMobile INC on 6/14/13.
//
//

#import <Foundation/Foundation.h>
@class Slide;

@interface IOHelper : NSObject
typedef void (^ CompletionBlock)(BOOL success, CMTime duration, Slide *slide, NSString * path);

-(void)putTogetherVideo:(NSArray *)videoPieces andAudioPieces:(NSArray *)audioPieces andCompletionBlock:(CompletionBlock)block forSlide:(Slide *)slide saveAtPath:(NSString *)path;

+(NSString*)getRandomFilePath; 
-(void)deletePath:(NSString *)path;
-(void)saveToLibraryFileAtPath:(NSString*)path;
-(void)cleanFiles:(NSArray *)files;

@end
