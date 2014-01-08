//
//  main.m
//  Recorder
//
//  Created by DJMobile INC on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

// From here to end of file added by Injection Plugin //

#ifdef DEBUG
static char _inMainFilePath[] = __FILE__;
static const char *_inIPAddresses[] = {"127.0.0.1", "10.0.0.10", NULL};

#define INJECTION_ENABLED
#import "/Applications/Injection Plugin.app/Contents/Resources/BundleInjection.h"
#endif
