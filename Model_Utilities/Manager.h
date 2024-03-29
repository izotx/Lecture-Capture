//
//  Manager.h
//  Created by DJMobile INC on 5/31/11.
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
@protocol LogoutDelegate <NSObject>
@required
- (void)logoutUser;
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
@property(nonatomic, assign) id <LogoutDelegate> logoutDelegate;
@property(strong) NSNumber * userId;

@property(strong) NSURL * url;


+(Manager *)sharedInstance;

-(void) loginWithLogin: (NSString *) login andPassword:(NSString *) pass;
-(void) registerWithName: (NSString *) displayName andEmail:(NSString *)email andPassword:(NSString *) pass;
-(void) logOut;
-(void) request;


@end
