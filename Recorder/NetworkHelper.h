//
//  NetworkHelper.h
//  Lecture Capture
//
//  Created by DJMobile INC on 5/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Video.h"
#import "Manager.h"


@interface NetworkHelper : NSObject
typedef void (^ BlockTest)();

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)uploadVideo:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath;

-(void)setCompletionBlocks:(BlockTest) successBlock andError:
(BlockTest) errorBlock;



@end
