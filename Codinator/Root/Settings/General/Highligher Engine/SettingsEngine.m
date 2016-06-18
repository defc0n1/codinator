//
//  SyntaxEngine.m
//  Codinator
//
//  Created by Vladimir Danila on 2/25/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

#import "SettingsEngine.h"
#import "NSUserDefaults+Additions.h"
#import "Codinator-Swift.h"


@implementation SettingsEngine

 
+ (void)restoreSyntaxSettings {
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
    
    backgroundOperation.completionBlock = ^{
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        
        // Save macros
        NSString *tagMacro = @"<.*?(>)";
        NSString *bracketsMacro = @"[\\[\\]]";
        NSString *keywordsMacro = @"(algin|width|height|color|text|border|bgcolor|description|name|content|href|src|charset|class|role|id|<!DOCTYPE html>|border)";
        NSString *stringMacro = @"\".*?(\"|$)";
        
        [userDefaults setObject:tagMacro forKey:@"Macro:3"];
        [userDefaults setObject:bracketsMacro forKey:@"Macro:4"];
        [userDefaults setObject:keywordsMacro forKey:@"Macro:5"];
        [userDefaults setObject:stringMacro forKey:@"Macro:6"];
        
        // Save fonts
        CGFloat size = 13;
        UIFont *normalFont = [UIFont fontWithName:@"SFMono-Regular" size:size];
        UIFont *italicFont = [UIFont fontWithName:@"SFMono-RegularItalic" size:size];
        UIFont *boldFont = [UIFont fontWithName:@"SFMono-Bold" size:size];

        [FontDefaults setWithFont:normalFont key:@"Font: 0"];
        [FontDefaults setWithFont:italicFont key:@"Font: 1"];
        [FontDefaults setWithFont:boldFont key:@"Font: 2"];
        
        // Save colors
        UIColor *tagColor = [SyntaxHighlighterDefaultColors purpleColor];
        UIColor *bracketsColor = [SyntaxHighlighterDefaultColors darkGoldColor];
        UIColor *keyworkdsColor = [SyntaxHighlighterDefaultColors silverGray];
        UIColor *stringColor = [SyntaxHighlighterDefaultColors stringRed];
        
        
        [userDefaults setColor:tagColor ForKey:@"Color: 3"];
        [userDefaults setColor:bracketsColor ForKey:@"Color: 4"];
        [userDefaults setColor:keyworkdsColor ForKey:@"Color: 5"];
        [userDefaults setColor:stringColor ForKey:@"Color: 6"];
        
        
        
        

        
        NSDictionary *tagDictionary = @{
                                        NSForegroundColorAttributeName : tagColor,
                                        NSFontAttributeName : normalFont
                                        };
        
        
        
        
        NSDictionary *bracketsDictionary = @{
                                             NSForegroundColorAttributeName : bracketsColor,
                                             NSFontAttributeName : boldFont
                                             };
        
        
        NSDictionary *keywordsDictionary = @{
                                             NSForegroundColorAttributeName : keyworkdsColor,
                                             NSFontAttributeName : boldFont
                                             };
        
        
        NSDictionary *stringDictionary = @{
                                           NSForegroundColorAttributeName : stringColor,
                                           NSFontAttributeName : normalFont
                                           };
        
        
        
        
        [userDefaults setDic:tagDictionary ForKey:@"Macro:3 Attribute"];
        [userDefaults setDic:bracketsDictionary ForKey:@"Macro:4 Attribute"];
        [userDefaults setDic:keywordsDictionary ForKey:@"Macro:5 Attribute"];
        [userDefaults setDic:stringDictionary ForKey:@"Macro:6 Attribute"];
        

    };
    
    
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
}




+ (void)reloadSyntaxLayers {
  
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
    
    backgroundOperation.completionBlock = ^{
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        for (NSInteger i = 3; i<= 6; i++) {
            NSString *saveKey = [NSString stringWithFormat:@"Macro:%li Attribute",(long)i];
            NSString *fontKey = [NSString stringWithFormat:@"Font: %li",(long)i];
            NSString *colorKey = [NSString stringWithFormat:@"Color: %li",(long)i];
            

            NSLog(@"%li", (long)i);
            
            NSDictionary *attributes = @{
                                         NSForegroundColorAttributeName : [userDefaults colorForKey: colorKey],
                                         NSFontAttributeName : [FontDefaults fontWithKey:fontKey]
                                         };
            
            [[NSUserDefaults standardUserDefaults] setDic:attributes ForKey:saveKey];
        }
        
        
    };
    
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];

    
}






+ (void)restoreServerSettings {
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
    
    backgroundOperation.completionBlock = ^{
    
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"CnLineNumber"];
        [userDefaults setBool:YES forKey:@"CnWebServer"];
        [userDefaults setBool:YES forKey:@"CnWebDavServer"];
        [userDefaults setBool:YES forKey:@"CnUploadServer"];
        
    
    };
        
    [[NSOperationQueue mainQueue] addOperation:backgroundOperation];

}


@end
