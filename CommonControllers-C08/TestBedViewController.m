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

#pragma mark - TBVC_03_Record_Trim_Save_Play_Video

@import MediaPlayer;

@interface TBVC_03_Record_Trim_Save_Play_Video ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverPresentationControllerDelegate>
@end

@implementation TBVC_03_Record_Trim_Save_Play_Video{
    UIPopoverPresentationController *popover;
    NSURL *playbackURL;
}

- (void)loadView{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([UIImagePickerController videoRecordingAvailable])
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self  action:@selector(recordVideo)];
}

- (void)recordVideo{
    if (popover) return;
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

#pragma mark TBVC_03_Record_Trim_Save_Play_Video - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self performDismiss];
    [self trimVideo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self performDismiss];
}

- (void)performDismiss{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self dismissViewControllerAnimated:YES completion:nil];
    else{
        // Deal with Pad
        
    }
}

#pragma mark Trim Video

- (void)trimVideo:(NSDictionary<NSString *,id> *)mediaInfo{
    NSURL *mediaURL = mediaInfo[UIImagePickerControllerMediaURL];
    NSString *urlPath = mediaURL.path;
    NSString *extension = urlPath.pathExtension;
    NSString *base = [urlPath stringByDeletingPathExtension];
    NSString *newPath = [NSString stringWithFormat:@"%@-trimmed.%@",base,extension];
    NSLog(@"Trimmed Video Path : %@",newPath);
    NSURL *fileURL = [NSURL fileURLWithPath:newPath];
    
    CGFloat editingStart = [mediaInfo[@"_UIImagePickerControllerVideoEditingStart"] floatValue];
    CGFloat editingEnd = [mediaInfo[@"_UIImagePickerControllerVideoEditingEnd"] floatValue];
    CMTime startTime = CMTimeMakeWithSeconds(editingStart, 1);
    CMTime endTime = CMTimeMakeWithSeconds(editingEnd, 1);
    CMTimeRange exportRange = CMTimeRangeFromTimeToTime(startTime, endTime);
    
    //PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[mediaURL] options:nil] firstObject];
    //PHAssetResource *resource = [PHAssetResource alloc]
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaURL options:nil];
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = fileURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    session.timeRange = exportRange;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            [self saveVideo:fileURL];
        }else if (session.status == AVAssetExportSessionStatusFailed){
            NSLog(@"AV export session failed");
        }else{
             NSLog(@"Export session status: %ld", (long)session.status);
        }
    }];
}

#pragma mark Save Video

- (void)saveVideo:(NSURL *)mediaURL{
    // check if video is compatible with album and save
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mediaURL.path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(mediaURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        playbackURL = [NSURL fileURLWithPath:videoPath];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playVideo)];
    }else{
        NSLog(@"Error saving video: %@", error.localizedFailureReason);
    }
}

#pragma mark Play Video

- (void)playVideo{
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:playbackURL];
    player.moviePlayer.allowsAirPlay = YES;
    player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self.navigationController presentMoviePlayerViewControllerAnimated:player];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:player.moviePlayer
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerLoadStateDidChangeNotification object:player.moviePlayer queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ((player.moviePlayer.loadState & MPMovieLoadStatePlayable) != 0) {
            [player.moviePlayer performSelector:@selector(play) withObject:nil afterDelay:0.5f];
        }
    }];
}

@end

#pragma mark - TBVC_06_Edit_Video

@interface TBVC_06_Edit_Video ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverPresentationControllerDelegate,UIVideoEditorControllerDelegate>
@end

@implementation TBVC_06_Edit_Video{
    UIPopoverPresentationController *popover;
    NSURL *mediaURL;
}

- (void)loadView{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor grayColor];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick Video", @selector(pickVideo));
}

#pragma mark Pick Video

- (void)pickVideo{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self performDismiss];
    
    popover = nil;
    mediaURL = info[UIImagePickerControllerMediaURL];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Edit", @selector(editVideo));
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self performDismiss];
}

- (void)performDismiss{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self dismissViewControllerAnimated:YES completion:nil];
    else{
        // Deal with Pad
        
    }
}

#pragma mark Edit Video

- (void)editVideo{
    if (popover) return;
    
    if ([UIVideoEditorController canEditVideoAtPath:mediaURL.path]) {
        UIVideoEditorController *editor = [UIVideoEditorController new];
        editor.videoPath = mediaURL.path;
        editor.delegate = self;
        [self presentViewController:editor animated:YES completion:nil];
    }else{
        NSLog(@"Cannot Edit Video");
    }
}

#pragma mark UIVideoEditorController Delegate

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    [self performDismiss];
    mediaURL = [NSURL fileURLWithPath:editedVideoPath];
    if (mediaURL){
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Save", @selector(saveVideo));
    }
    else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    [self performDismiss];
    mediaURL = nil;
    
    NSLog(@"Video edit failed: %@", error.localizedFailureReason);
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{
    [self performDismiss];
    mediaURL = nil;
}

- (void)saveVideo{
    NSLog(@"See TBVC_03_Record_Trim_Save_Play_Video Demo");
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickVideo));
}

@end

#pragma mark - TBVC_07_Email_Message_SocialPost

@import MessageUI;
@import Social;

@interface TBVC_07_Email_Message_SocialPost ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@end

@implementation TBVC_07_Email_Message_SocialPost{
    UIImageView *imageView;
    UISegmentedControl *seg;
}

- (void)loadView{
    // loadView 中必须对self.view进行初始化！！！！！！
    self.view = [UIView new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    imageView = [UIImageView newAutoLayoutView];
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    imageView.image = [UIImage imageNamed:@"CoverArt"];
    
    seg = [[UISegmentedControl alloc] initWithItems:[@"Email Message SinaWeibo" componentsSeparatedByString:@" "]];
    self.navigationItem.titleView = seg;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(send)];
}

- (void)send{
    switch (seg.selectedSegmentIndex) {
        case 0:
            [self sendMail];
            break;
        case 1:
            [self sendMessage];
            break;
        case 2:{
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
                [self postSocial:SLServiceTypeSinaWeibo];
            }
        }
            
            break;
        default:
            break;
    }
}

#pragma mark Send Mail

- (void)sendMail{
    MFMailComposeViewController *mcvc = [MFMailComposeViewController new];
    mcvc.mailComposeDelegate = self;
    [mcvc setSubject:@"Here’s a great photo!"];
    NSString *body = @"<h1>Check this out</h1>\
    <p>I snapped this image from the\
    <code><b>UIImagePickerController</b></code>.</p>";
    [mcvc setMessageBody:body isHTML:YES];
    [mcvc addAttachmentData:UIImagePNGRepresentation(imageView.image) mimeType:@"image/png" fileName:@"haha.png"];
    
    [self presentViewController:mcvc animated:YES completion:nil];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail was cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail was saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail was sent");
            break;
        default:
            break;
    }
}

#pragma mark Send Message

- (void)sendMessage{
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *mcvc = [MFMessageComposeViewController new];
        mcvc.messageComposeDelegate = self;
        mcvc.body = @"I'm reading the iOS Developer's Cookbook";
        if ([MFMessageComposeViewController canSendAttachments]) {
            [mcvc addAttachmentData:UIImagePNGRepresentation(imageView.image)  typeIdentifier:@"png" filename:@"haha.png"];
        }
        
        [self presentViewController:mcvc animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message was cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message failed");
            break;
        case MessageComposeResultSent:
            NSLog(@"Message was sent");
            break;
        default:
            break;
    }
}

#pragma mark Post Social

- (void)postSocial:(NSString *)serviceType{
    SLComposeViewController *cvc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    [cvc addImage:imageView.image];
    [cvc setInitialText:@"I'm reading the iOS Developer's Cookbook"];
    cvc.completionHandler = ^(SLComposeViewControllerResult result){
        switch (result)
        {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Cancelled");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Posted");
                break;
            default:
                break;
        }
    };
    
    [self presentViewController:cvc animated:YES completion:nil];
}
@end
