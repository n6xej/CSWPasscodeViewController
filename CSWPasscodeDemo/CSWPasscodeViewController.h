//
//  CSWPasscodeViewController.h
//  CSWPasscodeDemo
//
//  Created by Christopher Worley on 3/1/16.
//  Copyright © 2016 Christopher Worley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "LTHPasscodeViewController.h"
#import "LTHKeychainUtils.h"

#define PasscodeFilesDirectoryPath [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Intruder"]

@interface CSWPasscodeViewController : LTHPasscodeViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) UIImageView *cameraImageView;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) UIImage *cameraImage;

@end