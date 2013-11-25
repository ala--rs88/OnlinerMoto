//
//  OnlinerMotoFilterViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoFilterViewController.h"

@interface OnlinerMotoFilterViewController ()
{
    NSArray *_currentPickerData;
    
    NSDictionary *_inputFieldData;
    
    UIPickerView *_pickerView;
}

@end

@implementation OnlinerMotoFilterViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [_pickerView setShowsSelectionIndicator:YES];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    accessoryView.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    
    accessoryView.items = [NSArray arrayWithObjects:space, done, nil];
    
    NSArray *inputFields = [[NSArray alloc] initWithObjects:self.minPriceTextField,
                                                            self.maxPriceTextField,
                                                            self.minYearTextField,
                                                            self.maxYearTextField,
                                                            self.minEngineVolumeTextField,
                                                            self.maxEngineVolumeTextField, nil];
    
    NSArray *priceData = [[NSArray alloc] initWithObjects:@"Any", @"$100", @"$200", @"$500", @"$1000", @"$1500", @"$2000", nil];
    NSArray *yearData = [[NSArray alloc] initWithObjects:@"Any", @"1990", @"2000", @"2005", @"2010", @"2015", nil];
    NSArray *engineVolumeData = [[NSArray alloc] initWithObjects:@"Any", @"150 cc", @"250 cc", @"300 cc", @"400 cc", @"600 cc", @"800 cc", @"1000 cc", @"1200 cc", @"1500 cc", nil];
    
    NSArray *inputDatas = [[NSArray alloc] initWithObjects:priceData, priceData, yearData, yearData, engineVolumeData, engineVolumeData, nil];
    
    _inputFieldData = [[NSDictionary alloc] initWithObjects:inputDatas forKeys:inputFields];
    
    for (UITextField *textField in inputFields)
    {
        textField.inputView = _pickerView;
        textField.inputAccessoryView = accessoryView;
        textField.delegate = self;
    }
    
    
    [self.minPriceTextField.inputView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)doneTapped
{
    [[self findFirstResponderTextField ] resignFirstResponder];
}

- (UITextField *)findFirstResponderTextField
{

    for (UIView *subView in self.view.subviews)
    {
        if (subView.isFirstResponder && [subView isKindOfClass:[UITextField class]])
        {
            return (UITextField *)subView;
        }
    }
    
    return nil;
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_currentPickerData count];
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_currentPickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[self findFirstResponderTextField] setText:[_currentPickerData objectAtIndex:row]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _currentPickerData = _inputFieldData[textField];
    [_pickerView reloadAllComponents];
    
    return YES;
}


@end
