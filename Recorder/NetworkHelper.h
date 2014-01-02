//
//  NetworkHelper.h
//  Lecture Capture
//
//  Created by DJMobile INC on 5/22/13.
//
//

#import <Foundation/Foundation.h>
@class Lecture;
@class  Manager;
@interface NetworkHelper : NSObject
typedef void (^ BlockTest)();

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)uploadVideo:(Lecture *)lecture andManager:(Manager *)manager;

-(void)setCompletionBlocks:(BlockTest) successBlock andError:
(BlockTest) errorBlock;



@end
