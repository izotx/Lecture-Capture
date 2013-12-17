//
//  NewRecordingScreenViewController.h
//  Lecture Capture
//
//  Created by sadmin on 12/16/13.
//

#import <UIKit/UIKit.h>
@class Lecture;
@interface NewRecordingScreenViewController : UIViewController
@property(nonatomic,copy)void(^action)(BOOL a, NSString * title, Lecture * lecture);

-(void)actionWithBlock: (void (^)(BOOL a, NSString * title, Lecture * l))act;


@end
