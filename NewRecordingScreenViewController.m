//
//  NewRecordingScreenViewController.m
//  Lecture Capture
//
//  Created by sadmin on 12/16/13.
//
//
#import "RecorderViewController.h"
#import "NewRecordingScreenViewController.h"
#import "LectureAPI.h"

@interface NewRecordingScreenViewController ()<UITextFieldDelegate>
- (IBAction)createNew:(id)sender;
- (IBAction)cancel:(id)sender;
    @property (nonatomic,weak) IBOutlet UITextField * recordingTitleTextField;
@end

@implementation NewRecordingScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionWithBlock: (void (^)(BOOL a, NSString * title, Lecture *l))action;{
    self.action = [action copy];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  }

- (IBAction)createNew:(id)sender {
    NSString * name = (self.recordingTitleTextField.text.length>0)?self.recordingTitleTextField.text:@"Untitiled";
    
    
    Lecture * l = [LectureAPI createLectureWithName:name];
    
    self.action(YES,name, l);
}

- (IBAction)cancel:(id)sender {
   self.action(NO ,self.recordingTitleTextField.text,nil);
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
