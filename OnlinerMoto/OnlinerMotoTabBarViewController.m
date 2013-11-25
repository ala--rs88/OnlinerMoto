//
//  OnlinerMotoTabBarViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 25.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoTabBarViewController.h"
#import "OnlinerMotoVehiclesViewController.h"
#import "OnlinerMotoAppDelegateProtocol.h"

@interface OnlinerMotoTabBarViewController ()

@end

@implementation OnlinerMotoTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[OnlinerMotoVehiclesViewController class]])
    {
        [((OnlinerMotoVehiclesViewController *)viewController) checkForFilterChanges];
    }
}

@end
