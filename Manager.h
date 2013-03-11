//
//  Manager.h
//  Created by Janusz Chudzynski on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
@protocol LoginDelegate <NSObject>
@required
- (void)loginSuccess;
- (void)loginFailedWithMessage:(NSString *) message;
@end
@protocol RegisterDelegate <NSObject>

@required
- (void)registerSuccess;
- (void)registerFailed:(NSString *) message;;
@end



@interface Manager : NSObject {
    NSString * loginName;
    NSString * loginPassword;
    NSString * userName;
    NSString * docDir;
    NSMutableData * receivedData;
    NSURLConnection *loginConnection;
    NSURLConnection *registerConnection;
}
@property(nonatomic, retain) NSString *loginName;
@property(nonatomic, retain) NSString * loginPassword;
@property(nonatomic, retain) NSString * userName;

@property(nonatomic, assign) id <LoginDelegate> loginDelegate;
@property(nonatomic, assign) id <RegisterDelegate> registerDelegate;
@property(weak) NSNumber * userId;



+(Manager*)sharedManager;
-(void) loginWithLogin: (NSString *) login andPassword:(NSString *) pass;
-(void) registerWithName: (NSString *) displayName andEmail:(NSString *)email andPassword:(NSString *) pass;
-(void) logOut;
-(void) request;


@end
