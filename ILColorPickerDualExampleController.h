//
//  ILColorPickerExampleViewController.h
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSaturationBrightnessPickerView.h"
#import "ILHuePickerView.h"
@protocol ColorDelegate
-(void) colorPicked: (UIColor *) color forView: (int) viewIndex;


@end

@interface ILColorPickerDualExampleController : UIViewController<ILSaturationBrightnessPickerViewDelegate> {
    IBOutlet UIView *colorChip;
    IBOutlet ILSaturationBrightnessPickerView *colorPicker;
    IBOutlet ILHuePickerView *huePicker;
}

@property(nonatomic,assign)id <ColorDelegate> delegate;
@property(assign) int operationType;

- (IBAction)setColorByTapping:(id)sender;



@end
