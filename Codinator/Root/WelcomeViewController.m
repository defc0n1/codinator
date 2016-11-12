//
//  WelcomeViewController.m
//  Codinator
//
//  Created by Vladimir on 29/05/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//


@import CoreSpotlight;
@import MobileCoreServices;
@import LocalAuthentication;

#import "Codinator-Swift.h"

#import "WelcomeViewController.h"
#import "SettingsEngine.h"



///ZipImport
#import "ProjectZipImporterViewController.h"

///NSUserDefaults additions
#import "NSUserDefaults+Additions.h"

#import "Codinator-Swift.h"


@interface WelcomeViewController ()


//delegate
@property (strong, nonatomic) AppDelegate *appDelegate;

//UI
@property (weak, nonatomic) IBOutlet UIVisualEffectView *plusButtonSuperView;


//navigation
@property (strong, nonatomic) NSString *tmpPath;
@property (nonatomic) BOOL useTmpPath;


//Holding Objects
@property (strong, nonatomic) NSMutableArray <NSURL *>*oldProjectsArray;
@property (strong, nonatomic) NSMutableArray <NSURL *>*oldPlaygroundsArray;
@property (weak, nonatomic) NSString *zipPath;


//documents
@property (nonatomic, nonnull) NSMetadataQuery *query;

@property (nonatomic) NSString *playgroundsPath;

@end

@implementation WelcomeViewController
@synthesize projectsArray, playgroundsArray;
@synthesize document;
@synthesize projectIsOpened;
@synthesize query = _query;




- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        insets = UIEdgeInsetsMake(10, 0, 0, 0);
        UIEdgeInsets scrollInsets = insets;
        scrollInsets.top = 0;
        self.collectionView.scrollIndicatorInsets = scrollInsets;
    }
    
    self.collectionView.contentInset = insets;
    
    self.collectionView.prefetchDataSource = self;
    self.prefetchedImages = [[NSMutableDictionary alloc] init];
    
    
    
    //link to app delegate
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidReceiveNotification:) name:NSMetadataQueryDidUpdateNotification object:self.query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"reload" object:nil];
    
    [self performSelectorInBackground:@selector(setUp) withObject:nil];
    
    
    if ([self.traitCollection
         respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability ==
         UIForceTouchCapabilityAvailable))
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
    }
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    // delete old indexed files
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:nil];
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        
        if (document) {
            if (projectIsOpened) {
                [document closeWithCompletionHandler:^(BOOL success) {
                    if (success) {
                        projectIsOpened = NO;
                    }
                    else{
                        projectIsOpened = YES;
                    }
                }];
            }
        }
        
        
        NSString *rootPath = [AppDelegate storageURL].path;
        NSString *projectsDirPath = [rootPath stringByAppendingPathComponent:@"Projects"];
        NSString *playgroundsDirPath = [rootPath stringByAppendingPathComponent:@"Playground"];
        
        
        projectsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:projectsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
        playgroundsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:playgroundsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
        
        self.oldProjectsArray = projectsArray;
        self.oldPlaygroundsArray = playgroundsArray;
        
        
        [self indexProjects:projectsArray];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        
    }];
    
    
}



- (void)reload{
    NSString *rootPath = [AppDelegate storageURL].path;
    NSString *projectsDirPath = [rootPath stringByAppendingPathComponent:@"Projects"];
    NSString *playgroundsDirPath = [rootPath stringByAppendingPathComponent:@"Playground"];
    
    
    projectsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:projectsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
    playgroundsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:playgroundsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
    
    self.oldProjectsArray = projectsArray;
    self.oldPlaygroundsArray = playgroundsArray;
    
    
    
    [self.collectionView reloadData];
    [self indexProjects:projectsArray];
}


#pragma mark - Keyboard Shortcuts

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (NSArray *)keyCommands {
    
    return @[
             [UIKeyCommand keyCommandWithInput:@"N" modifierFlags:UIKeyModifierCommand action:@selector(newProjCommand) discoverabilityTitle:@"New Project"],
             [UIKeyCommand keyCommandWithInput:@"P" modifierFlags:UIKeyModifierCommand action:@selector(newPlayCommand) discoverabilityTitle:@"New Playground"],
             [UIKeyCommand keyCommandWithInput:@"S" modifierFlags:UIKeyModifierShift action:@selector(settingsCommand) discoverabilityTitle:@"Settings"],
             ];
}


- (void)newProjCommand{
    [self performSegueWithIdentifier:@"newProj" sender:self];
}

- (void)newPlayCommand{
    [self performSegueWithIdentifier:@"newPlay" sender:self];
}


- (void)settingsCommand{
    [self performSegueWithIdentifier:@"settings" sender:nil];
}






- (NSMetadataQuery *)query {
    if (!_query) {
        _query = [[NSMetadataQuery alloc]init];
        
        NSArray *scopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        _query.searchScopes = scopes;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", NSMetadataItemFSNameKey, @"*"];
        _query.predicate = predicate;
    }
    return _query;
}



#pragma mark - set up

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]



- (void)setUp {
    
    // Configure fonts
    NSString *macroKey = @"SF_Font_iOS_10";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL macro = [userDefaults boolForKey:macroKey];
    
    
    if (!macro) {
       [userDefaults setBool:YES forKey:macroKey];
        
        [SettingsEngine restoreSyntaxSettings];
        [SettingsEngine restoreServerSettings];
    }
}



#pragma mark - Sportlight




- (void)indexProjects:(NSArray *)projects{
    
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityNormal;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceUtility;
    
    backgroundOperation.completionBlock = ^{
        [projects enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            
            
            CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
            
            NSString *title = [projects[idx] lastPathComponent];
            [attributeSet setTitle:title.stringByDeletingPathExtension];
            
            NSString *description;
            if ([title.pathExtension isEqualToString:@"cnProj"]) {
                description = @"The Codinator project you've recently worked on";
            }
            else if ([title.pathExtension isEqualToString:@"zip"]) {
                description = @"The project you recently imported into Codinator";
            }
            else {
                description = @"A file that you have imported into Codinator";
            }
            
            [attributeSet setContentDescription:description];
            
            NSString *creator = @"Codinator";
            [attributeSet setCreator:creator];
            
            
            NSString *identifier = [NSString stringWithFormat:@"com.vladidanila.codinator.%@", title];
            
            CSSearchableItem *item = [[CSSearchableItem alloc]
                                      initWithUniqueIdentifier:title domainIdentifier:identifier attributeSet:attributeSet];
            
            
            
            [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler: nil];
            
            
        }];
        
    };
    
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
    
}

- (void)restoreUserActivityState:(NSUserActivity *)activity {
    
    
    if ([activity.activityType isEqualToString:@"com.apple.corespotlightitem"]) {
        NSDictionary *userInfo = activity.userInfo;
        
        if (userInfo) {
            
            
            NSString *root = [AppDelegate storageURL].path;
            NSString *projectsDirPath = [root stringByAppendingPathComponent:@"Projects"];
            
            NSString *projectName = userInfo[CSSearchableItemActivityIdentifier];
            
            NSString *documentPath = [projectsDirPath stringByAppendingPathComponent:projectName];
            
            
            BOOL isDir;
            if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath isDirectory:&isDir]) {
                
                // Import Zip
                if ([projectName containsString:@".zip"]) {
                    self.zipPath = [projectsDirPath stringByAppendingPathComponent:projectName];
                    [self performSegueWithIdentifier:@"importZip" sender:self];
                }
                
                // Open Project
                else if ([projectName containsString:@".cnProj"]){
                    NSString *path = [projectsDirPath stringByAppendingPathComponent:projectName];
                    
                    document = [[CodinatorDocument alloc] initWithFileURL:[NSURL fileURLWithPath:path]];
                    
                    [document openWithCompletionHandler:^(BOOL success) {
                        
                        if (success) {
                            
                            projectIsOpened = YES;
                            
                            self.projectsPath = path;
                            [self performSegueWithIdentifier:@"projectPop" sender:nil];
                            
                        }
                        else{
                            NSString *message = [NSString stringWithFormat:@"%@ can't be opened right now...", path.lastPathComponent];
                            UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *closeAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:closeAlert];
                            [self presentViewController:alert animated:YES completion:nil];
                            
                        }
                        
                    }];
                    
                }
                else {
                    
                    // Failed Opening other file type
                    NSString *message = [NSString stringWithFormat:@"Failed opening %@", projectName];
                    UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAlert];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
                
                
            }
            
            else {
                
                // Failed Opening other file type
                NSString *message = [NSString stringWithFormat:@"Document wasn't found"];
                UIAlertController *alert = [self alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:closeAlert];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            
        }
        
    }
}



#pragma mark - CollectionView Delegates

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        return CGSizeMake(164, 155);
    }
    else {
        return CGSizeMake(166, 155);
    }
}



- (void)dealWithiCloudDownloadForCell:(nonnull ProjectCollectionViewCell *)cell forIndexPath:(nonnull NSIndexPath *)indexPath andFilePath:(nonnull NSString *)path{
    
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityNormal;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceUtility;
    
    backgroundOperation.completionBlock = ^{
        
        
        NSError *error;
        BOOL downloadDone = [[NSFileManager defaultManager]startDownloadingUbiquitousItemAtURL:[NSURL fileURLWithPath:path isDirectory:NO] error:&error];
        
        if (downloadDone) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        }

    };
    
    
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
    
}



- (void)collectionView:(nonnull UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //Root Path
    NSString *root = [AppDelegate storageURL].path;
    
    //Custom Paths
    NSString *projectsDirPath = [root stringByAppendingPathComponent:@"Projects"];
    NSString *playgroundsDirPath = [root stringByAppendingPathComponent:@"Playground"];
    
    
    if (indexPath.section == 0) { //If projects is selected
        
        if ([[projectsArray[indexPath.row] pathExtension] isEqualToString:@"zip"]) {
            //Show project importer view
            
            self.zipPath = [projectsDirPath stringByAppendingPathComponent:[projectsArray[indexPath.row] lastPathComponent]];
            [self performSegueWithIdentifier:@"importZip" sender:self];
        }
        else if ([[projectsArray[indexPath.row] pathExtension] isEqualToString:@"cnProj"]){
            NSString *path = [projectsDirPath stringByAppendingPathComponent:[projectsArray[indexPath.row] lastPathComponent]];
            
            document = [[CodinatorDocument alloc] initWithFileURL:[NSURL fileURLWithPath:path]];
            
            Polaris *projectManager = [[Polaris alloc] initWithProjectPath:path];
            NSString *requiresTouchID = [projectManager getSettingsDataForKey:@"TouchID"];
			NSString *expectedPassword = [projectManager getSettingsDataForKey:@"TouchIDPassword"];

			if (expectedPassword == nil)
				expectedPassword = @"";

            NSLog(@"Requires TouchID: %@", requiresTouchID);
            
            [projectManager close];
            
            
            if ([requiresTouchID isEqualToString:@"YES"]) {
                
                LAContext *context = [[LAContext alloc] init];
                
                if ([context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil])
                {
                    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Unlock project" reply:^(BOOL success, NSError *authenticationError){
                        if (success) {
                            
                            projectIsOpened = YES;
                            
                            self.projectsPath = path;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self performSegueWithIdentifier:@"project" sender:nil];
                            });
                        }

						if (authenticationError) {

							UIAlertController *alertController = [UIAlertController
																  alertControllerWithTitle:@"Password required"
																  message:@"Enter the project password to unlock it."
																  preferredStyle:UIAlertControllerStyleAlert];


							[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
							 {
								 textField.placeholder = @"Password";
								 textField.secureTextEntry = YES;
								 textField.keyboardAppearance = UIKeyboardAppearanceDark;
							 }];


							UIAlertAction *cancelAction = [UIAlertAction
														   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
														   style:UIAlertActionStyleCancel
														   handler:^(UIAlertAction *action)
														   {
															   NSLog(@"Cancel action");
														   }];

							UIAlertAction *okAction = [UIAlertAction
													   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
													   style:UIAlertActionStyleDefault
													   handler:^(UIAlertAction *action)
													   {
														   NSString *password = alertController.textFields.firstObject.text;

														   if (![password isEqualToString: expectedPassword])
															   return;

														   projectIsOpened = YES;

														   self.projectsPath = path;
														   dispatch_async(dispatch_get_main_queue(), ^{
															   [self performSegueWithIdentifier:@"project" sender:nil];
														   });

													   }];
							
							[alertController addAction:cancelAction];
							[alertController addAction:okAction];
							
							dispatch_async(dispatch_get_main_queue(), ^{
								[self presentViewController:alertController animated:YES completion:nil];
							});
						}
                    }];
                }
                else {
					UIAlertController *alertController = [UIAlertController
														  alertControllerWithTitle:@"Password required"
														  message:@"Enter the project password to unlock it."
														  preferredStyle:UIAlertControllerStyleAlert];


					[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
					 {
						 textField.placeholder = @"Password";
						 textField.secureTextEntry = YES;
						 textField.keyboardAppearance = UIKeyboardAppearanceDark;
					 }];


					UIAlertAction *cancelAction = [UIAlertAction
												   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
												   style:UIAlertActionStyleCancel
												   handler:^(UIAlertAction *action)
												   {
													   NSLog(@"Cancel action");
												   }];

					UIAlertAction *okAction = [UIAlertAction
											   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
											   style:UIAlertActionStyleDefault
											   handler:^(UIAlertAction *action)
											   {
												   NSString *password = alertController.textFields.firstObject.text;

												   if (![password isEqualToString: expectedPassword])
													   return;

												   projectIsOpened = YES;

												   self.projectsPath = path;
												   dispatch_async(dispatch_get_main_queue(), ^{
													   [self performSegueWithIdentifier:@"project" sender:nil];
												   });

											   }];

					[alertController addAction:cancelAction];
					[alertController addAction:okAction];


					dispatch_async(dispatch_get_main_queue(), ^{
						[self presentViewController:alertController animated:YES completion:nil];
					});
				}                
            }
            else {
                
                projectIsOpened = YES;
                
                self.projectsPath = path;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"project" sender:nil];
                });

                
            }
            
            
        }
        else {
            
            // is no Project nor a zip file
            NSURL *projectURL = projectsArray[indexPath.row];
            UIAlertController *moveFileDialogue = [self moveFileAlertControllerWithPosition:[[collectionView cellForItemAtIndexPath:indexPath] frame] sourceView:self.collectionView andSelectedFilePath:projectURL.path];
            
            [self presentViewController:moveFileDialogue animated:YES completion:nil];
            
        }
        
        
    }
    else if (indexPath.section == 1){ // Playground selected
        
        
        NSString *fileName = [playgroundsArray[indexPath.row] lastPathComponent];
        NSString *path;
        
        if (self.useTmpPath) {
            path = [self.tmpPath stringByAppendingPathComponent:fileName];
        }
        else{
            path = [playgroundsDirPath stringByAppendingPathComponent:fileName];
        }
        
        
        if ([fileName.pathExtension isEqualToString:@"cnPlay"]) {
            
            self.playgroundsPath = path;
            
            [self performSegueWithIdentifier:@"playground" sender:self];
            
        }
    }
    
}





- (void)tableViewCellWasLongPressed:(UILongPressGestureRecognizer *)sender {
    
    
    CGPoint p = [sender locationInView:self.collectionView];
    CGRect position;
    position.origin.x = p.x;
    position.origin.y = p.y;
    position.size.height  = 0;
    position.size.width = 20;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    
    if (sender.state == UIGestureRecognizerStateBegan && indexPath) {
        
        NSString *deletePath;
        NSString *root = [AppDelegate storageURL].path;
        
        BOOL isProject = indexPath.section == 0;
        
        if (isProject) {
            NSString *projectsDirPath = [root stringByAppendingPathComponent:@"Projects"];
            deletePath = [projectsDirPath stringByAppendingPathComponent:[projectsArray[indexPath.row] lastPathComponent]];
        }
        else{
            NSString *playgroundsDirPath = [root stringByAppendingPathComponent:@"Playground"];
            deletePath = [playgroundsDirPath stringByAppendingPathComponent:[playgroundsArray[indexPath.row] lastPathComponent]];
        }
        
        
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * __nonnull action) {
            NSError *error;
            [[NSFileManager defaultManager]removeItemAtPath:deletePath error:&error];
            
            
            if (!error) {
                [self reloadData];
            }
            
            
        }];
        
        
        
        
        UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            
            // RENAME FILE DIALOGE
            NSString *message = [NSString stringWithFormat:@"Rename \"%@\"", deletePath.lastPathComponent.stringByDeletingPathExtension];
            
            UIAlertController *alert = [self alertControllerWithTitle:@"Rename" message:message preferredStyle:UIAlertControllerStyleAlert];

            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
                textField.placeholder = @"Projects new name";
                textField.keyboardAppearance = UIKeyboardAppearanceDark;
                textField.tintColor = [UIColor purpleColor];
            }];
            
            UIAlertAction *processAction = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
                
                NSString *extension = alert.textFields[0].text.pathExtension;
                if ([extension isEqualToString:@""]) {
                    extension = deletePath.pathExtension;
                }
                
                NSString *newName = [alert.textFields[0].text.stringByDeletingPathExtension stringByAppendingPathExtension:extension];
                NSString *newPath = [[deletePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
                
                // Rename file
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    BOOL isDir;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:deletePath isDirectory:&isDir] && isDir && [deletePath.pathExtension isEqualToString:@"cnProj"]) {
                        Polaris *polaris = [[Polaris alloc] initWithProjectPath:deletePath];
                        [polaris updateSettingsValueForKey:@"ProjectName" withValue:newName.stringByDeletingPathExtension];
                    }
                    
                    [[NSFileManager defaultManager] moveItemAtPath:deletePath toPath:newPath error:nil];
                    [self reloadData];
                    
                });
                
            }];
            
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:processAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            
        }];
        
        
        NSOperation *backgroundOperation = [[NSOperation alloc] init];
        backgroundOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
        backgroundOperation.qualityOfService = NSOperationQualityOfServiceUserInteractive;
        
        backgroundOperation.completionBlock = ^{
            
            
            UIAlertController *popup = [self alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            
            // Move to project -> Just if is file in Project Dir
            if (isProject && ![deletePath.pathExtension isEqualToString:@"cnProj"]) {
                
                UIAlertAction *moveToProj = [UIAlertAction actionWithTitle:@"Move into Project" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        // Create a new AlertController with a list of the projects
                        UIAlertController *fileLister = [self moveFileAlertControllerWithPosition:position sourceView:self.collectionView andSelectedFilePath:deletePath];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController: fileLister animated:YES completion:nil];
                        });
                    });
                    
                }];
                
                [popup addAction:moveToProj];
            }
            
            
            // Add previous actions
            [popup addAction:renameAction];
            [popup addAction:deleteAction];
            
            
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
                [popup dismissViewControllerAnimated:true completion:nil];
            }];
            
            [popup addAction:cancel];
            
            
            popup.popoverPresentationController.sourceView = self.collectionView;
            popup.popoverPresentationController.sourceRect = position;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self presentViewController:popup animated:YES completion:nil];
            });
            
            
        };
        
        
        [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
        
        
        
    }
    
    
    
    
}


- (UIAlertController *)moveFileAlertControllerWithPosition:(CGRect)position sourceView:(UIView *)view andSelectedFilePath:(NSString *)filePath {
    
    UIAlertController *fileLister = [self alertControllerWithTitle:@"Select a Project" message:@"The file will me moved to the selected one" preferredStyle:UIAlertControllerStyleActionSheet];

    
    [projectsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSURL *projectURL = obj;
        
        if ([projectURL.pathExtension isEqualToString:@"cnProj"]) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:projectURL.lastPathComponent.stringByDeletingPathExtension style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
                NSError *error;
                NSURL *newURL = [[projectURL URLByAppendingPathComponent:@"Assets" isDirectory:YES] URLByAppendingPathComponent:filePath.lastPathComponent];
                
                [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:filePath isDirectory:NO] toURL:newURL error:&error];
                
                if (error) {
                    
                    // Error message popup
                    UIAlertController *errorAlert = [self alertControllerWithTitle:[error localizedDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [errorAlert addAction:cancelAction];
                    
                    [self presentViewController:errorAlert animated:YES completion:nil];
                    
                }
                else {
                    [self reloadData];
                }
                
            }];
            
            [fileLister addAction:action];
        }
    }];
    
    
    if (fileLister.actions.count == 0) {
        fileLister = [self alertControllerWithTitle:@"No Projects" message:nil preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        fileLister.popoverPresentationController.sourceView = self.collectionView;
        fileLister.popoverPresentationController.sourceRect = position;
    }
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [fileLister addAction:cancelAction];
    
    
    return fileLister;
}



#pragma mark - iCloud Data management & Tableview Reloading



- (void)queryDidReceiveNotification:(NSNotification *)notification {
    NSArray *results = [self.query results];
    
    for(NSMetadataItem *item in results) {
        
        NSOperation *backgroundOperation = [[NSOperation alloc] init];
        backgroundOperation.queuePriority = NSOperationQueuePriorityNormal;
        backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
        
        backgroundOperation.completionBlock = ^{
            
            
            NSString *downloaded = [item valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusNotDownloaded];
            
            if (!downloaded) {
                
                
                NSURL *fileURL = [item valueForAttribute:NSMetadataItemURLKey];
                
                NSError *error;
                [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:&error];
                
            }
            
            
            
        };
        
        
        [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
    }
    
    
    [self reloadData];
}



- (void)reloadData{
    
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityNormal;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceUtility;
    
    backgroundOperation.completionBlock = ^{
        
        self.prefetchedImages = [[NSMutableDictionary alloc] init];
        
        //Root Path
        NSString *root = [AppDelegate storageURL].path;
        
        //Custom Paths
        NSString *projectsDirPath = [root stringByAppendingPathComponent:@"Projects"];
        NSString *playgroundsDirPath = [root stringByAppendingPathComponent:@"Playground"];
        
        
        projectsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:projectsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
        playgroundsArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:playgroundsDirPath isDirectory:YES] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
        
        if (!self.oldProjectsArray) {
            self.oldProjectsArray = [[NSMutableArray alloc] init];
        }
        
        if (!self.oldPlaygroundsArray) {
            self.oldPlaygroundsArray = [[NSMutableArray alloc] init];
        }
        
        if (![projectsArray isEqualToArray:self.oldProjectsArray] | ![playgroundsArray isEqualToArray:self.oldPlaygroundsArray]) {
            
            self.oldProjectsArray = projectsArray;
            self.oldPlaygroundsArray = playgroundsArray;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            
        }
        
    };
    
    
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
}





- (IBAction)plusDidPush:(id)sender {


    UIAlertAction *projectAction = [UIAlertAction actionWithTitle:@"Project" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        
        
        UIAlertController *projectAlert = [self alertControllerWithTitle:nil message:@"Do you want to create a new project or import an existing one?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        projectAlert.popoverPresentationController.sourceView = self.navigationController.navigationBar;
        projectAlert.popoverPresentationController.barButtonItem = sender;

        // Set background color
        UIView * firstView = projectAlert.view.subviews.firstObject;
        UIView * nextView = firstView.subviews.firstObject;
        nextView.backgroundColor = self.collectionView.backgroundColor;
        projectAlert.view.tintColor = self.view.tintColor;


        UIAlertAction *createProjectAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            [self performSegueWithIdentifier:@"newProj" sender:self];
        }];
        
        
        UIAlertAction *cancelProjectCreationAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
            [projectAlert dismissViewControllerAnimated:true completion:nil];
        }];
        
        UIAlertAction *importProjectAction = [UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            [self performSegueWithIdentifier:@"import" sender:self];
        }];
        
        
        [projectAlert addAction:createProjectAction];
        [projectAlert addAction:importProjectAction];
        [projectAlert addAction:cancelProjectCreationAction];
        
        [self presentViewController:projectAlert animated:true completion: nil];
        
    }];
    
    UIAlertAction *playgroundAction = [UIAlertAction actionWithTitle:@"Playground" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        
        [self performSegueWithIdentifier:@"newPlay" sender:self];
        
    }];
    
    

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    

    UIAlertController *newDoc = [self alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [newDoc addAction:projectAction];
    [newDoc addAction:playgroundAction];
    [newDoc addAction:cancelAction];
    
    newDoc.popoverPresentationController.sourceView = self.plusButtonSuperView;
    newDoc.popoverPresentationController.barButtonItem = sender;
    newDoc.view.tintColor = self.view.tintColor;

    [self presentViewController:newDoc animated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)safariViewControllerDidFinish:(nonnull SFSafariViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"importZip"]){
        
        ProjectZipImporterViewController *destViewController = segue.destinationViewController;
        
        
        NSString *root = [AppDelegate storageURL].path;
        NSString *projectsDirPath = [root stringByAppendingPathComponent:@"Projects"];
        
        
        destViewController.filePathToZipFile = self.zipPath;
        destViewController.projectsPath = projectsDirPath;
        
    }
    else if ([segue.identifier isEqualToString:@"playground"]) {
        
        PlaygroundViewController *destViewController = segue.destinationViewController;
        destViewController.filePath = self.playgroundsPath;
        
    }
    else if ([segue.identifier isEqualToString:@"project"] || [segue.identifier isEqualToString:@"projectPop"]) {
        ProjectMainViewController *destViewController = segue.destinationViewController;
        destViewController.path = self.projectsPath;
    }else if ([segue.identifier isEqualToString:@"settings"]){
        
    } else if ([segue.identifier isEqualToString:@"popover"]) {
        UINavigationController *destViewController = segue.destinationViewController;
        destViewController.popoverPresentationController.backgroundColor = destViewController.viewControllers.firstObject.view.backgroundColor;
    }
}



#pragma mark - Trait Collection

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self reload];
}




@end
