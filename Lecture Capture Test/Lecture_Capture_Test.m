//
//  Lecture_Capture_Test.m
//  Lecture Capture Test
//
//  Created by Janusz Chudzynski on 1/7/13.
//
//

#import "Lecture_Capture_Test.h"
#import "RecorderViewController.h"

@implementation Lecture_Capture_Test

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testComposition
{
    RecorderViewController * r = [[RecorderViewController alloc]init];
    
    NSMutableArray * a = [NSMutableArray arrayWithCapacity:0];
    [a addObject:@"1_output.mov"];
    [a addObject:@"2_output.mov"];
    
    [r putFilesTogether:a];
    
}

@end
