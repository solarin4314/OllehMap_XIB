//
//  OMPeoplePickerNavigationController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 7. 9..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMPeoplePickerNavigationController.h"

@interface OMPeoplePickerNavigationController ()

@end

@implementation OMPeoplePickerNavigationController

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
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setFrame:CGRectMake(0, 37, 320, [[UIScreen mainScreen] bounds].size.height - 20 -37)];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}



@end
