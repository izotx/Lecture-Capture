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
@interface LectureAPI()
@property int index;
@property (nonatomic,strong) NSArray * orderedSlides;
@end

@implementation LectureAPI

 -(id)initWithLecture:(Lecture *)lecture;
{
    if(self = [super init]){
        self.currentLecture = lecture;
        NSSortDescriptor * ns = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        _orderedSlides = [[lecture.slides allObjects]sortedArrayUsingDescriptors:@[ns]];
        self.currentSlide = [_orderedSlides objectAtIndex:0];
        _index = 0;
        
    }
    return self;
}


+ (Slide *)addNewSlideToLecture:(Lecture *)lecture afterSlide:(Slide*)previousSlide{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    Slide * slide= [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:delegate.managedObjectContext];
    [lecture addSlidesObject:slide];
    slide.order = [NSNumber numberWithInt:previousSlide.order.intValue + 1];
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

-(id) next;{
    if(_index+1<self.orderedSlides.count){
        _index++;
        self.currentSlide = self.orderedSlides[_index];

    }
    return self.currentSlide;
}

-(id) previous;{
    if(_index-1>=0){
        _index--;
        self.currentSlide = self.orderedSlides[_index];
    }
    return self.currentSlide;
}


@end
