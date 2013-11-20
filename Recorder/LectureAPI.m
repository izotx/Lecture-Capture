//
//  LectureAPI.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/19/13.
//
//

#import "LectureAPI.h"
#import "Lecture.h"
#import "AppDelegate.h"

@implementation LectureAPI
//creates a new lecture
+ (id)createLectureWithName:(NSString *)name{
 
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    Lecture * lecture= [NSEntityDescription insertNewObjectForEntityForName:@"Lecture" inManagedObjectContext:delegate.managedObjectContext];
    
    
    lecture.name  = name;
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        return nil;
    }
    return lecture;
}

+ (id)saveLecture:(Lecture*)lecture;{
    //opens lecture for editing
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication];
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        return nil;
    }
    return nil;
}

+ (id)removeLecture:(Lecture*)lecture;{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication];
    [delegate.managedObjectContext delete:lecture];
    
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
        return nil;
    }

    
    return nil;
}

+ (id)compile;{return nil;
    //get all slides
    
    //convert them into video
    
    
    
}

@end
