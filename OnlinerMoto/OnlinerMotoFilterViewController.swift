//
//  OnlinerMotoFilterViewController.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 14.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoFilterViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak private var minPriceTextField: UITextField!
    @IBOutlet weak private var maxPriceTextField: UITextField!
    @IBOutlet weak private var minYearTextField: UITextField!
    @IBOutlet weak private var maxYearTextField: UITextField!
    @IBOutlet weak private var minEngineVolumeTextField: UITextField!
    @IBOutlet weak private var maxEngineVolumeTextField: UITextField!
    
    private var textFields: [UITextField]!

    private var currentPickerData: [String]?
    private var textFieldsOptions = [Int:[String]]()
    private var pickerView = UIPickerView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.textFields = [
            self.minPriceTextField, self.maxPriceTextField,
            self.minYearTextField, self.maxYearTextField,
            self.minEngineVolumeTextField, self.maxEngineVolumeTextField]
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.showsSelectionIndicator = true
        
        var accessoryView = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        accessoryView.barStyle = UIBarStyle.BlackTranslucent
        
        var space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneTapped")
        
        accessoryView.items = [space, done]
        
        var inputFieldsKeys = [Int]()
        
        for textField in self.textFields
        {
            textField.inputView = self.pickerView
            textField.inputAccessoryView = accessoryView
            textField.delegate = self
            textField.text = "Any"
            
            if let key = getKeyByTextField(textField)
            {
                if let options = getOptionsForTextField(textField)
                {
                    self.textFieldsOptions[key] = options
                }
            }
        }
        
        self.minPriceTextField.becomeFirstResponder()
    }
    
    func doneTapped()
    {
        getFirstResponderFromTextFields(self.textFields)?.resignFirstResponder()
    }
    
    // MARK: - UIPickerView DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        var number = self.currentPickerData?.count ?? 0
        return number
    }
    
    // MARK: -
    
    // MARK: - UIPickerView Gelegate

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30.0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        var title = self.currentPickerData?[row] ?? ""
        return title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        getFirstResponderFromTextFields(self.textFields)?.text = self.currentPickerData![row]
    }
    
    // MARK: -
    
    // MARK: - UITextField Delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        self.currentPickerData = getOptionsForTextField(textField)
        self.pickerView.reloadAllComponents()
        
        if let currentOptionIndex = getCurrentOptionIndexForTextField(textField)
        {
            self.pickerView.selectRow(currentOptionIndex, inComponent: 0, animated: false)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        updateGlobalFilter()
    }
    
    // MARK: -
    
    private func updateGlobalFilter()
    {
        var globalFilter = getGlobalFilter()
        
        globalFilter.minPrice = self.minPriceTextField.text.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).toInt()? ?? 0
        globalFilter.maxPrice = self.maxPriceTextField.text.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).toInt()? ?? 0
        
        globalFilter.minYear = self.minYearTextField.text.toInt()? ?? 0
        globalFilter.maxYear = self.maxYearTextField.text.toInt()? ?? 0
        
        globalFilter.minEngineVolume = self.minEngineVolumeTextField.text.stringByReplacingOccurrencesOfString(" cc", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).toInt()? ?? 0
        globalFilter.maxEngineVolume = self.maxEngineVolumeTextField.text.stringByReplacingOccurrencesOfString(" cc", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).toInt()? ?? 0
        
        notifyGlobalFilterIsChanged()
    }
    
    private func notifyGlobalFilterIsChanged()
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        appDelegate.isFilterAlreadyApplied = false
    }
    
    private func getCurrentOptionIndexForTextField(textField: UITextField) -> Int?
    {
        var index: Int?
        if let options = getOptionsForTextField(textField)
        {
            index = find(options, textField.text)
        }
        
        return index
    }
    
    private func getFirstResponderFromTextFields(textFields: [UITextField]) -> UITextField?
    {
        var firstResponderTextField: UITextField? = nil
        
        for textField in textFields
        {
            if (textField.isFirstResponder())
            {
                firstResponderTextField = textField
                break
            }
        }
        
        return firstResponderTextField
    }
    
    private func getOptionsForTextField(textField: UITextField) -> [String]?
    {
        var options: [String]?
        switch (textField)
        {
        case self.minPriceTextField, self.maxPriceTextField:
            options = ["Any", "$100", "$200", "$500", "$1000", "$1500", "$2000", "$3000", "$4000", "$5000",
                "$6000", "$8000", "$10000", "$15000", "$25000", "$40000", "$60000"]
        case self.minYearTextField, self.maxYearTextField:
            options = ["Any", "2014", "2013", "2012", "2011", "2010", "2009",
                "2008", "2007", "2006", "2005", "2004", "2003", "2002",
                "2001", "2000", "1995", "1990",  "1985", "1980"]
        case self.minEngineVolumeTextField, self.maxEngineVolumeTextField:
            options = ["Any", "150 cc", "250 cc", "300 cc", "400 cc",
                "600 cc", "800 cc", "1000 cc", "1200 cc", "1500 cc"]
        default:
            options = nil
        }
        
        return options
    }
    
    private func getKeyByTextField(textField: UITextField) -> Int?
    {
        var key: Int? = find(self.textFields, textField)
        return key
    }
    
    private func getTextFieldByKey(key: Int) -> UITextField
    {
        var textField = self.textFields[key]
        return textField
    }
    
    // MARK: - AppDelegate accessors
    
    private func getGlobalFilter() -> VehicleItemFilter
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        return appDelegate.vehicleItemFilter
    }
    
    // MARK: -
}