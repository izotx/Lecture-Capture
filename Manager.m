//
//  Manager.m
//  PhysicsPreparationApp
//
#pragma mark URL Section
#define LOGIN_URL @"http://djmobilesoftware.com/remediator/login.php"
#define REGISTER_URL @"http://djmobilesoftware.com/remediator/register.php"

#import "Manager.h"
@implementation Manager
@synthesize  loginName, loginPassword;
@synthesize userName;
@synthesize loginDelegate;
@synthesize registerDelegate;
@synthesize userId;
static Manager* _sharedManager = nil;


+(Manager*)sharedManager
{
	@synchronized([Manager class])
	{
		if (!_sharedManager)
			[[self alloc] init];
		return _sharedManager;	
    }
	return nil;
}

+(id)alloc
{
	@synchronized([Manager class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
        NSArray * arrayPaths=NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES);
        
        docDir = [arrayPaths objectAtIndex:0];
	}
	return self;
}

#pragma mark register
-(void) registerWithName: (NSString *) displayName andEmail:(NSString *)email andPassword:(NSString *) pass{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:REGISTER_URL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    NSString * params = [[NSString alloc] initWithFormat:@"email=%@&password=%@&displayName=%@",email,pass,displayName];
    // create the connection with the request
    // and start loading the data
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    registerConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (registerConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
        [registerConnection start];
       
    } else {
        // Inform the user that the connection failed.
    }
    

}


#pragma mark Login and Logout
-(void) loginWithLogin: (NSString *) login andPassword:(NSString *) pass{
    //Connecting to the server passing login/logout information
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:LOGIN_URL]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    NSString * params = [[NSString alloc] initWithFormat:@"email=%@&password=%@",login,pass];
    // create the connection with the request
    // and start loading the data
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    loginConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (loginConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } 
    else {
        // Inform the user that the connection failed.
    }
}

-(void) logOut{
    //
    self.userId =nil;
    
}

#pragma mark request
-(void) request{
    // Create the request.
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
   if([connection isEqual:registerConnection])
   {

       //Parsing JSON
       NSError *error = nil;
      
       NSDictionary *receivedMessage = [NSJSONSerialization
                              JSONObjectWithData:receivedData
                              options:NSJSONReadingMutableLeaves
                              error:&error];
       if(!error){
           NSNumber *successNumber = [receivedMessage  objectForKey:@"success"];

           BOOL success = [successNumber boolValue];
           
           if(success)
           {
               self.userId= [receivedMessage  objectForKey:@"userId"];
               [registerDelegate registerSuccess];
           }
           else{
               NSString * errorMessage = [receivedMessage objectForKey:@"message"];
               [registerDelegate registerFailed:errorMessage];               
           }
       }
       else{
          NSLog(@"Error %@", [error debugDescription]); 
           
       }
   }
   if([connection isEqual:loginConnection])
   {
      
       //Parsing JSON
       NSError *error = nil;
       
       NSDictionary *receivedMessage = [NSJSONSerialization
                                JSONObjectWithData:receivedData
                                options:NSJSONReadingMutableLeaves
                                error:&error];
        NSLog(@"Login Connection Finished %@",receivedMessage);
       if(!error){
           NSNumber *successNumber = [receivedMessage  objectForKey:@"success"];
           BOOL success = [successNumber boolValue];
           
           if(success)
           {
               self.userId= [receivedMessage  objectForKey:@"userId"];
               [loginDelegate loginSuccess];
           }
           else{
               NSString * errorMessage = [receivedMessage objectForKey:@"message"];
               [loginDelegate loginFailedWithMessage:errorMessage];
           }
       }
       else{
        NSLog(@"Error %@", [error debugDescription]); 
       }
   }    
}

-(NSURLRequest *)postRequestWithURL: (NSString *)url

                               data: (NSData *)data   
                           fileName: (NSString*)fileName
{
    
    // from http://www.cocoadev.com/index.pl?HTTPFileUpload
    
    //NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:url]];
    //[urlRequest setURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    NSString *myboundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",myboundary];
    [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    //[urlRequest addValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [NSMutableData data]; //[NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName]dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[NSData dataWithData:data]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}





@end
