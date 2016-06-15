//
//  UIImagePickerController+GM.m
//  CommonControllers-C08
//
//  Created by BobZhang on 16/6/15.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

#import "UIImagePickerController+GM.h"
@import MobileCoreServices;

@implementation UIImagePickerController (GM)
+ (BOOL)videoRecordingAvailable{
    BOOL available = NO;
    // The source type must be available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // And the media type must include the movie type
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediaTypes containsObject:(NSString *)kUTTypeMovie])
            available = YES;
    }
    return available;
};

@end
