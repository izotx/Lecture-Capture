//
//  NetworkHelper.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 5/22/13.
//
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Video.h"
#import "Manager.h"


@interface NetworkHelper : NSObject
typedef void (^ BlockTest)(int);


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)uploadVideo:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath;

-(void)testTheBlock:(BlockTest) blockTest;



@end
