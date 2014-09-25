//
//  ViewController.h
//  Popcliqs
//
//  Created by Praveen Kansara on 17/08/13.
//  Copyright (c) 2013 PaniPuri Soft Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField*   objUserNameTextField;
@property (nonatomic, weak) IBOutlet UITextField*   objPasswordTextField;
@property (nonatomic, weak) IBOutlet UIButton*      objLoginButton;

- (IBAction)loginButtonPressed:(UIButton*)sender;

- (IBAction)forgotPasswordButtonPressed:(UIButton*)lobjButton;
- (IBAction)signUpButtonPressed:(UIButton*)lobjButton;

- (IBAction)clearPreviousData;
- (IBAction)addNewData;

@end
