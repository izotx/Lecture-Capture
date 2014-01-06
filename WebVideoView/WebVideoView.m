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
@property (nonatomic,strong)MPMoviePlayerController *mp;
@end
@implementation WebVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

-(void)setupView{
    //_webView = [[UIWebView alloc]initWithFrame:self.bounds];
   // _webView.delegate =self;
   // [self addSubview:_webView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void)dealloc{

}


-(void) loadVideoWithURL:(NSURL *) url{
    //url = outputURL;
    _mp = [[MPMoviePlayerController alloc]initWithContentURL:url];
    _mp.controlStyle = MPMovieControlStyleFullscreen;
    _mp.shouldAutoplay = NO;
    [_mp prepareToPlay];
    [_mp.view setFrame: self.bounds];  // player's frame must match parent's
    [self addSubview: _mp.view];
    
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


    NSNumber *reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonUserExited) {
        
        // done button clicked!
        
    }

}



@end
