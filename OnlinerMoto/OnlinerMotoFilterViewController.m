//
//  OnlinerMotoFilterViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoFilterViewController.h"
#import "OnlinerMotoAppDelegateProtocol.h"
#import "VehicleItemFilter.h"

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
    
    NSMutableArray *inputFieldsKeys = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [inputFields count]; i++)
    {
        UITextField *textField = inputFields[i];
        
        textField.inputView = _pickerView;
        textField.inputAccessoryView = accessoryView;
        textField.delegate = self;
        textField.text = @"Any";
        textField.tag = i;
        [inputFieldsKeys addObject:[NSNumber numberWithInteger:textField.tag]];
    }
    
    NSArray *priceData = [[NSArray alloc] initWithObjects:@"Any", @"$100", @"$200", @"$500", @"$1000", @"$1500", @"$2000", nil];
    NSArray *yearData = [[NSArray alloc] initWithObjects:@"Any", @"1990", @"2000", @"2005", @"2010", @"2015", nil];
    NSArray *engineVolumeData = [[NSArray alloc] initWithObjects:@"Any", @"150 cc", @"250 cc", @"300 cc", @"400 cc", @"600 cc", @"800 cc", @"1000 cc", @"1200 cc", @"1500 cc", nil];
    
    NSArray *inputDatas = [[NSArray alloc] initWithObjects:priceData, priceData, yearData, yearData, engineVolumeData, engineVolumeData, nil];
    
    _inputFieldData = [[NSDictionary alloc] initWithObjects:inputDatas forKeys:inputFieldsKeys];
    
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

- (void)notifyGlobalFilterIsChanged
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    theDelegate.isFilterAlreadyApplied = NO;
}

- (void)updateGlobalFilter
{
    VehicleItemFilter *globalFilter = [self getGlobalFilter];
    
    globalFilter.minPrice = [self.minPriceTextField.text isEqualToString:@"Any"] ? 0 :[[self.minPriceTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""] integerValue];
    globalFilter.maxPrice = [self.maxPriceTextField.text isEqualToString:@"Any"] ? 0 :[[self.maxPriceTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""] integerValue];
    
    globalFilter.minYear= [self.minYearTextField.text isEqualToString:@"Any"] ? 0 :[self.minYearTextField.text integerValue];
    globalFilter.maxYear= [self.maxYearTextField.text isEqualToString:@"Any"] ? 0 :[self.maxYearTextField.text integerValue];
    
    globalFilter.minEngineVolume = [self.minEngineVolumeTextField.text isEqualToString:@"Any"] ? 0 :[[self.minEngineVolumeTextField.text stringByReplacingOccurrencesOfString:@" cc" withString:@""] integerValue];
    globalFilter.maxEngineVolume = [self.maxEngineVolumeTextField.text isEqualToString:@"Any"] ? 0 :[[self.maxEngineVolumeTextField.text stringByReplacingOccurrencesOfString:@" cc" withString:@""] integerValue];
    
    [self notifyGlobalFilterIsChanged];
}

#pragma mark - AppDelegate accessors

- (VehicleItemFilter *)getGlobalFilter
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    
	return (VehicleItemFilter *) theDelegate.vehicleItemFilter;
}

- (NSInteger)getCurrentSelectedRowIndexForPickerForTextField:(UITextField *)textField
{
    NSArray *dataForCurrentTextField = _inputFieldData[[NSNumber numberWithInteger:textField.tag]];
    NSString *currentTextFieldText = textField.text;
    
    NSUInteger index = [dataForCurrentTextField indexOfObject:currentTextFieldText];
    
    return index == NSNotFound ? 0 : index;
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
    return 30.0f;
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
    _currentPickerData = _inputFieldData[[NSNumber numberWithInteger:textField.tag]];
    [_pickerView reloadAllComponents];
    
    NSInteger currecntSelectedRowIndexForPicker = [self getCurrentSelectedRowIndexForPickerForTextField:textField];
    
    [_pickerView selectRow:currecntSelectedRowIndexForPicker inComponent:0 animated:YES];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateGlobalFilter];
}

@end
