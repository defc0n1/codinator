//
//  WelcomeViewController.h
//  Codinator
//
//  Created by Vladimir on 29/05/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

@import SafariServices;
#import "CodinatorDocument.h"
#import "ProjectCollectionViewCell.h"

@interface WelcomeViewController : UIViewController <UITextFieldDelegate, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate>

@property (strong, nonatomic, nonnull) NSMutableArray *projectsArray;
@property (strong, nonatomic, nonnull) NSMutableArray *playgroundsArray;
@property (strong, nonatomic, nonnull) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong, nullable) CodinatorDocument *document;

@property (strong, nonatomic, nullable) NSString *forceTouchPath;

@property (nonatomic) BOOL projectIsOpened;
@property (nonatomic, nullable) NSString *projectsPath;

@property (nonatomic, strong, nonnull) NSDictionary *prefetchedImages;

- (void)dealWithiCloudDownloadForCell:(nonnull ProjectCollectionViewCell *)cell forIndexPath:(nonnull NSIndexPath *)indexPath andFilePath:(nonnull NSString *)path;
- (void)indexProjects:(nonnull NSArray *)projects;
- (void)restoreUserActivityState:(nonnull NSUserActivity *)activity;
- (void)reloadData;


- (void)tableViewCellWasLongPressed:(nonnull UILongPressGestureRecognizer *)sender;


@end
