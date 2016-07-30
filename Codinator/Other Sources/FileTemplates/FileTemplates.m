//
//  FileTemplates.m
//  Codinator
//
//  Created by Vladimir Danila on 21/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

#import "FileTemplates.h"

@implementation FileTemplates



+ (NSString *)htmlTemplateFileForName:(NSString *)name {
    
    NSString *indexBody = [NSString stringWithFormat:
@"<!DOCTYPE html> \n\
<html> \n\
    <head> \n\
        <meta charset=\"UTF-8\"> \n\
        <title>%@</title> \n\
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"> \n\
        %@\n\
    </head> \n\
    <body> \n\
    \n\
        <h1>%@</h1> \n\
        <p>Hello world</p>		\n\
        \n\
    </body> \n\
</html>", name,
            
@"<link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\"> \n\
    <script src=\"script.js\"></script>",name];

    
    
    return indexBody;
}


+ (NSString *)cssTemplateFile {
    NSString *cssBody =
@"/* Normalize.css brings consistency to browsers. \n\
https://github.com/necolas/normalize.css */ \n\
\n\
@import url(https://cdn.jsdelivr.net/normalize/2.1.3/normalize.min.css); \n\
\n\
/* A fresh start */  \n";
    
    return cssBody;
}

+ (NSString *)jsTemplateFileWithCopyright:(NSString *)copyright {
    NSString *jsTemplate = [NSString stringWithFormat:@"// %@ \n", copyright];
    return jsTemplate;
}

+ (NSString *)txtTemplateFile {
    return @"";
}

+ (NSString *)phpTemplateFile {
    return @"<?php \n ?>";
}



@end
