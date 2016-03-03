//
//  CSWPasscodeViewController.m
//  CSWPasscodeDemo
//
//  Created by Christopher Worley on 3/1/16.
//  Copyright © 2016 Christopher Worley. All rights reserved.
//
//  declare these 5 functions in LTHPasscodeViewController.h
//  so they can be overriden
//
//- (void)_resetUI;
//- (void)_dismissMe;
//- (void)_setupNavBarWithLogoutTitle:(NSString *)logoutTitle;
//- (void)_denyAccess;
//- (void)_handleTouchIDFailureAndDisableTouchID:(BOOL)disableTouchID;
//

#import "CSWPasscodeViewController.h"
#if !(TARGET_IPHONE_SIMULATOR)
#import <LocalAuthentication/LocalAuthentication.h>
#endif

#ifndef LTHPasscodeViewControllerStrings
#define LTHPasscodeViewControllerStrings(key) \
[[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LTHPasscodeViewController" ofType:@"bundle"]] localizedStringForKey:(key) value:@"" table:self.localizationTableName]
#endif


@interface CSWPasscodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView      *animatingView;
@property (nonatomic, strong) UIView      *complexPasscodeOverlayView;
@property (nonatomic, strong) UITextField *passcodeTextField;
@property (nonatomic, strong) UITextField *firstDigitTextField;
@property (nonatomic, strong) UITextField *secondDigitTextField;
@property (nonatomic, strong) UITextField *thirdDigitTextField;
@property (nonatomic, strong) UITextField *fourthDigitTextField;
@property (nonatomic, strong) UITextField *fithDigitTextField;
@property (nonatomic, strong) UITextField *sixthDigitTextField;
@property (nonatomic, strong) UILabel     *failedAttemptLabel;
@property (nonatomic, strong) UILabel     *enterPasscodeLabel;
@property (nonatomic, strong) UIButton    *OKButton;
@property (nonatomic, assign) BOOL        isUsingNavBar;
@property (nonatomic, assign) BOOL        isUsingTouchID;
@property (nonatomic, assign) BOOL        useFallbackPasscode;
@property (nonatomic, assign) BOOL        isFourDigits;

#if !(TARGET_IPHONE_SIMULATOR)
@property (nonatomic, strong) LAContext   *context;
#endif
@end

@implementation CSWPasscodeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupCamera];
	
	// Create Folder, if it doesn't exsits
	if(![[NSFileManager defaultManager] fileExistsAtPath:PasscodeFilesDirectoryPath])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:PasscodeFilesDirectoryPath
			   withIntermediateDirectories:YES attributes:nil error:nil];
	}
}

- (void)takePicture
{
	if (self.device)
	{
		UIImage *tmpmage = self.cameraImage;
		UIImage *tmpImage = [self rotateUIImage:tmpmage clockwise:YES];
		NSData *jpegData = UIImagePNGRepresentation(tmpImage);
		NSString *uniqueID = [self GetUUID];
		
		self.filePath = [PasscodeFilesDirectoryPath stringByAppendingFormat:
						 @"/%@.png",uniqueID];
		
		NSString *myPath =  [self.filePath stringByStandardizingPath];
		[jpegData writeToFile:myPath atomically:NO];
	}
}

- (NSString *)GetUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return (__bridge NSString *) string;
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
	
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

- (void)setupCamera
{
	NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	
	self.device = nil;
	for(AVCaptureDevice *device in devices)
	{
		if([device position] == AVCaptureDevicePositionFront)
			self.device = device;
	}
	
	if (self.device == nil)
	{
		return;
	}
	
	AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
	AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
	output.alwaysDiscardsLateVideoFrames = YES;
	
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[output setSampleBufferDelegate:self queue:queue];
	
	NSString* key = (NSString *) kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[output setVideoSettings:videoSettings];
	
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:input];
	[self.captureSession addOutput:output];
	[self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
	[self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferLockBaseAddress(imageBuffer,0);
	uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGImageRef newImage = CGBitmapContextCreateImage(newContext);
	
	CGContextRelease(newContext);
	CGColorSpaceRelease(colorSpace);
	
	self.cameraImage = [UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationDownMirrored];
	
	CGImageRelease(newImage);
	
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}


- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
	CGSize size = sourceImage.size;
	UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
	[[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

#pragma warning Override These functions
// declare these 5 functions in LTHPasscodeViewController.h
//- (void)_resetUI;
//- (void)_dismissMe;
//- (void)_setupNavBarWithLogoutTitle:(NSString *)logoutTitle;
//- (void)_denyAccess;
//- (void)_handleTouchIDFailureAndDisableTouchID:(BOOL)disableTouchID;
//

- (void)_resetUIPic {
	[self takePicture];
	[self _resetUI];
}

- (void)_denyAccess {
	[self takePicture];
	[super _denyAccess];
}

#if !(TARGET_IPHONE_SIMULATOR)
- (void)_handleLocalTouchIDFailureAndDisableTouchID:(BOOL)disableTouchID error:(NSError *)error{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (disableTouchID) {
			_isUsingTouchID = NO;
			self.allowUnlockWithTouchID = NO;
		}
		
		_useFallbackPasscode = YES;
		_animatingView.hidden = NO;
		
		BOOL usingNavBar = _isUsingNavBar;
		NSString *logoutTitle = usingNavBar ? self.navBar.items.firstObject.leftBarButtonItem.title : @"";
		
		switch (error.code) {
			case LAErrorAuthenticationFailed:
				// bad fingerprint 3 times
				NSLog(@"LAErrorAuthenticationFailed");
				[self _resetUIPic];
				break;
				
			case LAErrorTouchIDLockout:
				//exceeded touchID tries bad input
				NSLog(@"LAErrorTouchIDLockout");
				[self _resetUIPic];
				break;

			default:
				[self _resetUI];
				break;
		}

		if (usingNavBar) {
			_isUsingNavBar = usingNavBar;
			[self _setupNavBarWithLogoutTitle:logoutTitle];
		}
	});
	
	self.context = nil;
}

- (void)_setupFingerPrint {
	if (!self.context && self.allowUnlockWithTouchID && !_useFallbackPasscode) {
		self.context = [[LAContext alloc] init];
		
		NSError *error = nil;
		if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
			if (error) {
				return;
			}
			
			_isUsingTouchID = YES;
			[_passcodeTextField resignFirstResponder];
			_animatingView.hidden = YES;
			
			// Authenticate User
			[self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
						 localizedReason:LTHPasscodeViewControllerStrings(self.touchIDString)
								   reply:^(BOOL success, NSError *error) {
									   
									   if (error) {
										   [self _handleLocalTouchIDFailureAndDisableTouchID:false error:error];
										   return;
									   }
									   
									   if (success) {
										   dispatch_async(dispatch_get_main_queue(), ^{
											   [self _dismissMe];
											   
											   if ([self.delegate respondsToSelector: @selector(passcodeWasEnteredSuccessfully)]) {
												   [self.delegate performSelector: @selector(passcodeWasEnteredSuccessfully)];
											   }
										   });
										   
										   self.context = nil;
									   }
									   else {
										   [self _handleTouchIDFailureAndDisableTouchID:false];
									   }
								   }];
		}
		else {
			[self _handleTouchIDFailureAndDisableTouchID:true];
		}
	}
	else {
		[self _handleTouchIDFailureAndDisableTouchID:true];
	}
}
#endif

@end
