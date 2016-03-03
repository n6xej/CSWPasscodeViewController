//
//  CSWCollectionViewController.m
//  CSWPasscodeDemo
//
//  Created by Christopher Worley on 3/3/16.
//  Copyright © 2016 Christopher Worley. All rights reserved.
//

#import "CSWCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define PasscodeFilesDirectoryPath [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Intruder"]

@interface CSWCollectionViewController ()

@end

@implementation CSWCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
	
	NSString *filePath = PasscodeFilesDirectoryPath;
	
	NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath];

    // Do any additional setup after loading the view.
	self.fileInfo = [self scanFilesURL:url];

}
- (IBAction)tapMe:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableArray *)scanFilesURL:(NSURL *)directoryURL
{
	// Create a local file manager instance
	NSFileManager *localFileManager=[[NSFileManager alloc] init];
 
	// Enumerate the directory (specified elsewhere in your code)
	// Request the two properties the method uses, name and isDirectory
	// Ignore hidden files
	// The errorHandler: parameter is set to nil. Typically you'd want to present a panel
	NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:directoryURL
												  includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
																			  NSURLIsDirectoryKey,nil]
																	 options:NSDirectoryEnumerationSkipsHiddenFiles
																errorHandler:nil];
 
	// An array to store the all the enumerated file names in
	NSMutableArray *infoArray=[NSMutableArray array];
	
 
	// Enumerate the dirEnumerator results, each value is stored in allURLs
	for (NSURL *theURL in dirEnumerator)
	{
		
		// Retrieve the file name. From NSURLNameKey, cached during the enumeration.
		NSString *fileName;
		[theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
		
		// Retrieve whether a directory. From NSURLIsDirectoryKey, also
		// cached during the enumeration.
		NSNumber *isDirectory;
		[theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
		
		// Ignore files under directory
		if ([isDirectory boolValue]==YES)
		{
			[dirEnumerator skipDescendants];
		}
		else
		{
			if ([fileName containsString:@".png"]) {
				
			NSMutableDictionary *info = [NSMutableDictionary dictionary];
			
			[info setObject:theURL forKey:@"theURL"];
			[info setObject:fileName forKey:@"fileName"];
			
			[infoArray addObject:info];
		}

		}
	}
	return infoArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.fileInfo count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	
	NSMutableDictionary *info = [self.fileInfo objectAtIndex:indexPath.row];
	
	NSString *fileName = [info objectForKey:@"theURL"];
	
	NSData *data = [[NSData alloc]initWithContentsOfFile:fileName];
	UIImage *image = [[UIImage alloc]initWithData:data];
	
	[cell setBackgroundColor:[UIColor whiteColor]];
	
	CGRect frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
	
	UIImageView *imageV = [[UIImageView alloc]initWithFrame:frame];
	imageV.image = image;
	[imageV setContentMode:UIViewContentModeScaleAspectFit];
	[imageV setBackgroundColor:[UIColor blackColor]];
	
	[cell.contentView addSubview:imageV];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
