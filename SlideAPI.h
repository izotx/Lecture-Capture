//
//  SlideAPI.h
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/22/13.
//
//

#import <Foundation/Foundation.h>
@class Slide;

@interface SlideAPI : NSObject
@property (nonatomic, strong) NSMutableArray * audioPieces;
@property (nonatomic, strong) NSMutableArray * moviePieces;
@property (nonatomic, strong) Slide * slide;
+(void)save;



@end
