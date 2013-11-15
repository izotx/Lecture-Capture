//
//  InfoViewController.m
//  Recorder
//
//  Created by DJMobile INC on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
          NSLog(@"Alloc Init");
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //check the web
    NSString *webPDFPath = @"http://djmobilesoftware.com/screencapture/helpfiles/lecturecapture.pdf";
    NSURL *url = [NSURL URLWithString:webPDFPath];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
     
    NSLog(@"View Did Appear");
}

- (void)webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error: %@",[error debugDescription]);
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"LectureCapturePDF" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:pdfPath];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    webView.opaque = YES;
    webView.backgroundColor = [UIColor clearColor];
    webView.delegate=self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setWebView:nil];
    [super viewWillDisappear:animated];
    // Release any retained subviews of the main view.
}

//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation==UIInterfaceOrientationLandscapeRight || interfaceOrientation==UIInterfaceOrientationLandscapeLeft);
//	
//}

- (IBAction)dimissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
