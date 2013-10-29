//
//  Utilities.m
//  Lecture Capture
//
//  Created by DJMobile INC on 8/8/12.
//
//

#import "Utilities.h"

@implementation Utilities
-(NSString* ) timeConverter:(int)durationInSeconds{
    NSString * durationText;
    
    if(durationInSeconds>= 60&&durationInSeconds<3600)
    {
        int minutes = durationInSeconds/60;
        int seconds = durationInSeconds%60;
        if(minutes<10)
        {
            if(seconds<10)
            {
                durationText=[NSString stringWithFormat:@"00:0%d:0%d",minutes,seconds];
            }
            else{
                durationText=[NSString stringWithFormat:@"00:0%d:%d",minutes,seconds];
                
            }
        }
        else{
            if(seconds<10)
            {
                durationText=[NSString stringWithFormat:@"00:%d:0%d",minutes,seconds];
            }
            else{
                durationText=[NSString stringWithFormat:@"00:%d:%d",minutes,seconds];
            }
        }
        
    }
    if(durationInSeconds<60)
    {
        
        int seconds = durationInSeconds%60;
        if(seconds<10)
        {
            durationText=[NSString stringWithFormat:@"00:00:0%d", seconds];
        }
        else{
            durationText=[NSString stringWithFormat:@"00:00:%d", seconds];
        }
    }
    if(durationInSeconds>3600)
    {
        int hours= durationInSeconds/3600;
        int minutes = durationInSeconds%3600;
        int seconds = durationInSeconds%60;
        //=[NSString stringWithFormat:@"%d:%d:%d",hours,minutes,seconds];
        if(minutes<10)
        {
            if(seconds<10)
            {
                durationText=[NSString stringWithFormat:@"%d:0%d:0%d",hours,minutes,seconds];
            }
            else{
                durationText=[NSString stringWithFormat:@"%d:0%d:%d",hours,minutes,seconds];
                
            }
        }
        else{
            if(seconds<10)
            {
                durationText=[NSString stringWithFormat:@"%d:%d:0%d",hours,minutes,seconds];
            }
            else{
                durationText=[NSString stringWithFormat:@"%d:%d:%d",hours,minutes,seconds];
            }
        }
        
        
    }
    return durationText;
}

@end
