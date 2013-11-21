//
//  NonRotatingImagePicker.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/21/13.
//
//

#import "NonRotatingImagePicker.h"

@interface NonRotatingImagePicker ()

@end

@implementation NonRotatingImagePicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate
{
    return NO;
}



@end
