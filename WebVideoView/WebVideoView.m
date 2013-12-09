//
//  WebVideoView.m
//  Lecture Capture
//
//  Created by Janusz Chudzynski on 11/22/13.
//
//

#import "WebVideoView.h"
@interface WebVideoView()
    @property(nonatomic,strong)UIWebView * webView;
@end
@implementation WebVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
    return self;
}

-(void)setupView{
    _webView = [[UIWebView alloc]initWithFrame:self.bounds];
    _webView.delegate =self;
    [self addSubview:_webView];
}


-(void) loadVideoWithURL:(NSURL *) url{
    //url = outputURL;
    
    NSString *videoHTML = [NSString stringWithFormat: @"<html><head><style></style></head><body><video id='video_with_controls' height='%f' width='%f' controls autobuffer autoplay='false'><source src='%@' title='' poster='icon2.png' type='video/mp4' durationHint='durationofvideo'/></video><ul></body></html>",_webView.frame.size.height,_webView.frame.size.width, url];
    
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [_webView loadHTMLString:videoHTML baseURL:nil];
}

-(void)doneButtonClick:(NSNotification*)aNotification{
    
}


- (void)moviePlaybackChange:(NSNotification *)notification
{
    
}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayerController];
    [moviePlayerController.view removeFromSuperview];
}


@end
