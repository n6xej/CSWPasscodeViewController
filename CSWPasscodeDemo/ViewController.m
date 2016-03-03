//
//  ViewController.m
//  CSWPasscodeDemo
//
//  Created by Christopher Worley on 3/1/16.
//  Copyright © 2016 Christopher Worley. All rights reserved.
//

#import "ViewController.h"
#import "CSWPasscodeViewController.h"
#import <LocalAuthentication/LAContext.h>

@interface ViewController () <LTHPasscodeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *enablePasscode;
@property (nonatomic, strong) IBOutlet UIButton *testPasscode;
@property (nonatomic, strong) IBOutlet UIButton *changePasscode;
@property (nonatomic, strong) IBOutlet UIButton *turnOffPasscode;
@property (nonatomic, strong) IBOutlet UISwitch *typeSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *touchIDSwitch;
@property (nonatomic, strong) IBOutlet UILabel  *touchIDLabel;
@property (nonatomic, strong) IBOutlet UILabel  *typeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[CSWPasscodeViewController sharedUser].delegate = self;
	[CSWPasscodeViewController sharedUser].maxNumberOfAllowedFailedAttempts = 2;

#if (TARGET_IPHONE_SIMULATOR)
	[_touchIDSwitch setHidden:YES];
	[_touchIDLabel setHidden:YES];
#endif
	
	[self _refreshUI];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)_refreshUI {
	if ([CSWPasscodeViewController doesPasscodeExist]) {
		_enablePasscode.enabled = NO;
		_changePasscode.enabled = YES;
		_turnOffPasscode.enabled = YES;
		_testPasscode.enabled = YES;
		
		_changePasscode.backgroundColor = [UIColor colorWithRed:0.50f green:0.30f blue:0.87f alpha:1.00f];
		_testPasscode.backgroundColor = [UIColor colorWithRed:0.000f green:0.645f blue:0.608f alpha:1.000f];
		_enablePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
		_turnOffPasscode.backgroundColor = [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f];
	}
	else
	{
		_enablePasscode.enabled = YES;
		_changePasscode.enabled = NO;
		_turnOffPasscode.enabled = NO;
		_testPasscode.enabled = NO;
		
		_changePasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
		_enablePasscode.backgroundColor = [UIColor colorWithRed:0.000f green:0.645f blue:0.608f alpha:1.000f];
		_testPasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
		_turnOffPasscode.backgroundColor = [UIColor colorWithWhite: 0.8f alpha: 1.0f];
	}
	
	_typeSwitch.on = [[CSWPasscodeViewController sharedUser] isSimple];
	_touchIDSwitch.on = [[CSWPasscodeViewController sharedUser] allowUnlockWithTouchID];
}

- (IBAction)_enablePasscode:(id)sender {
	[self showLockViewForEnablingPasscode];
}


- (IBAction)_testPasscode:(id)sender {
	[[CSWPasscodeViewController sharedUser] clearCurrentlyOnScreenFlag];
	[self showLockViewForTestingPasscode];
}

- (IBAction)_changePasscode:(id)sender {
	[self showLockViewForChangingPasscode];
}

- (IBAction)_turnOffPasscode:(id)sender {
	[self showLockViewForTurningPasscodeOff];
}

- (IBAction)_switchPasscodeType:(UISwitch *)sender {
	[[CSWPasscodeViewController sharedUser] setIsSimple:sender.isOn
									   inViewController:self
												asModal:YES];
}

- (IBAction)_touchIDPasscodeType:(UISwitch *)sender {
	[[CSWPasscodeViewController sharedUser] setAllowUnlockWithTouchID:sender.isOn];
}

- (void)showLockViewForEnablingPasscode {
	[[CSWPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self
																			asModal:YES];
}

- (void)showLockViewForTestingPasscode {
	[[CSWPasscodeViewController sharedUser] showLockScreenWithAnimation:YES
															 withLogout:NO
														 andLogoutTitle:nil];
}


- (void)showLockViewForChangingPasscode {
	[[CSWPasscodeViewController sharedUser] showForChangingPasscodeInViewController:self asModal:YES];
}


- (void)showLockViewForTurningPasscodeOff {
	[[CSWPasscodeViewController sharedUser] showForDisablingPasscodeInViewController:self
																			 asModal:YES];
}

- (BOOL)isTouchIDAvailable {
	if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
		return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
	}
	return NO;
}

# pragma mark - CSWPasscodeViewController Delegates -
- (IBAction)imagesFolder:(id)sender {

}

- (void)passcodeViewControllerWillClose {
	NSLog(@"Passcode View Controller Will Be Closed");
	[self _refreshUI];
}

- (void)maxNumberOfFailedAttemptsReached {
	[CSWPasscodeViewController deletePasscodeAndClose];
	NSLog(@"Max Number of Failed Attemps Reached");
}

- (void)passcodeWasEnteredSuccessfully {
	NSLog(@"Passcode Was Entered Successfully");
}

- (void)logoutButtonWasPressed {
	NSLog(@"Logout Button Was Pressed");
}

@end
