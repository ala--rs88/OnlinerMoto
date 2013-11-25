//
//  OnlinerMotoFilterViewController.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlinerMotoFilterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *minPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *minYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *minEngineVolumeTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxEngineVolumeTextField;

@end
