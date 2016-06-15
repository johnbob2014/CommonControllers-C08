//
//  TestBedViewController.m
//  CommonControllers-C08
//
//  Created by BobZhang on 16/6/15.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

#import "TestBedViewController.h"
#import "Utility.h"
#import "UIView+AutoLayout.h"

@import AssetsLibrary;

#pragma mark - TBVC_01_ImagePicker

@interface TBVC_01_ImagePicker ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverPresentationControllerDelegate>
@end

@implementation TBVC_01_ImagePicker{
    UIImageView *imageView;
    UISwitch *editSwitch;
    
    UIPopoverPresentationController *popover;
}

- (void)loadView{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor grayColor];
    
    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick Image", @selector(pickImage));
    
    editSwitch = [UISwitch new];
    UILabel *editLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 13)];
    editLabel.text = @"Edits";
    self.navigationItem.leftBarButtonItems= @[[[UIBarButtonItem alloc] initWithCustomView:editLabel],
                                              [[UIBarButtonItem alloc] initWithCustomView:editSwitch]];
}

- (void)pickImage{
    if (popover) return;
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = editSwitch.isOn;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark TBVC_01_ImagePicker - UIImagePickerControllerDelegate


@end
