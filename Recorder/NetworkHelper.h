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
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)uploadVideo:(NSString *) path title:(NSString *)title video:(Video *)currentVideo andManager:(Manager *)manager andVideoPath:(NSString *)videoPath;


@end
