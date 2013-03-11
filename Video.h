//
//  Video.h
//  Recorder
//
//  Created by Janusz Chudzynski on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * video_description;
@property (nonatomic, retain) NSString * video_path;
@property (nonatomic, retain) NSString * video_size;
@property (nonatomic, retain) NSString * video_url;

@end
