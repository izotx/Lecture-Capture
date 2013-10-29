Lecture-Capture
===============
App let's user record sound and finger-based drawing inside app's canvas.

Architecture:

Recording Folder:
 
RecorderViewController - View Controller that is responsible for:
- starting/pausing/stopping recording
- managing colors of background and drawings
- managing changing of background images
- managing the camera preview (through CaptureSessionManager class)

Recording Process:
  User taps on the Record Button and that executes the  
  -(IBAction)startRecording:(id)sender method.
  Inside the startRecoring method I call startRecording method of recordingScreenView which is an instance of 
  ScreenCapture class. 
  
  ScreenCaptureView is responsible for several important tasks:
    - setting up the instance of a PaintView class - app's canvas place where user is drawing using his/hers fingers
    - setting up the recording session. App is using AVAssetWriter and samples the paintView's image property and then using 
      [self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000)]; writes an image to a video.
    
  PaintView - it's a subclass of UIImageView
    - it's a canvas. I'm using a UIBezierPath and touchesBegan, touchesMoved and etc. to 
        
      
        
      
      
