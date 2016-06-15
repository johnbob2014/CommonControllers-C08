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
#import "UIImagePickerController+GM.h"

@import MobileCoreServices;
@import Photos;

#pragma mark - TBVC_01_Pick_Snap_Image

@interface TBVC_01_Pick_Snap_Image ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverPresentationControllerDelegate>
@end

@implementation TBVC_01_Pick_Snap_Image{
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
    
    UIBarButtonItem *pickItem = BARBUTTON(@"Pick Image", @selector(pickImage));
    UIBarButtonItem *snapItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(snapImage)];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.navigationItem.rightBarButtonItems = @[pickItem,snapItem];
    }else{
        self.navigationItem.rightBarButtonItem = pickItem;
    }
    
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

- (void)snapImage{
    if (popover) return;
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = editSwitch.isOn;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)performDismiss{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark TBVC_01_Pick_Snap_Image - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    if (!image) {
        if (assetURL) {
            image = [self loadImageFromAssetURL:assetURL];
        }else{
            NSLog(@"Cannot retrieve an image from the selected item. Giving up.");
        }
    }
    imageView.image = image;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //如果是拍摄的照片，存入照片库
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    [self performDismiss];
}

- (UIImage *)loadImageFromAssetURL:(NSURL *)assetURL{
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil] firstObject];
    __block UIImage *assetImage = nil;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc]init];
        PHImageRequestID imageRequestID = [imageManager requestImageForAsset:asset
                                targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                               contentMode:PHImageContentModeAspectFit
                                options:nil
                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                assetImage = [result copy];
                            }
        ];
        NSLog(@"PHImageRequestID : %d",imageRequestID);
    }
    return assetImage;
}

// UIImageWriteToSavedPhotosAlbum() completionSelector
- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *)error contextInfo:(void *)contextInfo{
    // Handle the end of the image write process
    if (!error)
        NSLog(@"Image written to photo album");
    else
        NSLog(@"Error writing to photo album: %@", error.localizedFailureReason);

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self performDismiss];
}
@end

#pragma mark - TBVC_03_Record_PlayBack_Trim_Video

@interface TBVC_03_Record_PlayBack_Trim_Video ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverPresentationControllerDelegate>
@end

@implementation TBVC_03_Record_PlayBack_Trim_Video{
    UIPopoverPresentationController *popover;
    NSURL *playbackURL;
}

- (void)loadView{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([UIImagePickerController videoRecordingAvailable])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self  action:@selector(recordVideo)];
}

@end

