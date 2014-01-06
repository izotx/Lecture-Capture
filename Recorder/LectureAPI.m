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
#import "Slide.h"
#import  "IOHelper.h"
#import "NetworkHelper.h"
#import  "Manager.h"

@implementation LectureAPI

#warning UPLOADING LECTURE
+(void)uploadLecture: (Lecture *)lecture;{
    NetworkHelper * nh = [[NetworkHelper alloc]init];
    [nh uploadVideo:lecture andManager:[Manager sharedInstance]];

}

+(void)saveLecturetoLibrary: (Lecture *)lecture;{
    IOHelper * h = [[IOHelper alloc]init];
    //check if file exist
    [h saveToLibraryFileAtPath:lecture.filepath];
}

+ (Slide *)addNewSlideToLecture:(Lecture *)lecture afterSlide:(Slide*)previousSlide{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    Slide * slide= [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:delegate.managedObjectContext];
    [lecture addSlidesObject:slide];
    if(previousSlide){
        slide.order = [NSNumber numberWithInt:previousSlide.order.intValue + 1];
    }

    slide.selected = @1;
    slide.lecture = lecture;
    NSError *error;
    [delegate.managedObjectContext save:&error];
    if(error){
        NSLog(@"Error %@",error.debugDescription);
   
    }
    return slide;
}

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
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
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
