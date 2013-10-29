//
//  IOHelper.h
//  Lecture Capture
//
//  Created by DJMobile INC on 6/14/13.
//
//

#import <Foundation/Foundation.h>
@interface IOHelper : NSObject
typedef void (^ CompletionBlock)(BOOL success, CMTime duration);

-(void)putTogetherVideo:(NSArray *)videoPieces andAudioPieces:(NSArray *)audioPieces andCompletionBlock:(CompletionBlock)block saveAtPath:(NSString *)path;

-(NSString*)getRandomFilePath;


@end
