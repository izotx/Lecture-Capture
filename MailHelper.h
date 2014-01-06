//
//  MailHelper.h
//  MathFractions
//
//  Created by Janusz Chudzynski on 11/25/13.
//  Copyright (c) 2013 UWF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailHelper : NSObject

-(void)sendEmailFromVC:(id)vc;
-(void)shareURL:(id)sender;
- (void)contactSupport:(id)sender;


@end
