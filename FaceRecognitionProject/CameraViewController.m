//
//  CameraViewController.m
//  FaceRecognitionProject
//
//  Created by Andy on 2018/3/8.
//  Copyright © 2018年 AndyLLL. All rights reserved.
//

#import "CameraViewController.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController * imagePicker;
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initImageView];
    [self initPicker];
}

- (void)initImageView{
//    _imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    [self.view addSubview:_imageView];
}
//UIImagePickerController初始化
- (void)initPicker{
    _imagePicker = [[UIImagePickerController alloc]init];
    _imagePicker.delegate = self;
    [self takePhoto];
}
//拍照或者相册选择照片
- (void)takePhoto{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    }else {
    	//打开照相机只能在真机进行
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = sourceType;
            self.imagePicker.allowsEditing = false;
            //   self.imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [self presentViewController:_imagePicker animated:YES completion:nil];
            
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }

}

- (void)detect:(UIImage *)image{
    //图像识别能力：可以在cidetectoreaccuracyhigh（较强的处理能力）与CIDetectorAccuracyLow(较弱的处理能力)中选择
    NSDictionary * opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];

    //将图像转成CIImage
    CIImage * faceImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector * faceDetecor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    //识别人脸数组
    NSArray * features = [faceDetecor featuresInImage:faceImage];
    //得到图片尺寸
    CGSize inputImageSize = [faceImage extent].size;
    //将image沿y轴对称
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移
    transform = CGAffineTransformScale(transform, 0, -inputImageSize.height);
    //取出所有人脸
    for (CIFaceFeature * faceFeature in features) {
        //获取人脸的frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        CGSize viewSize = _imageView.bounds.size;
        CGFloat scale = MIN(viewSize.width / inputImageSize.width,
                            viewSize.height / inputImageSize.height);
        CGFloat offsetX = (viewSize.width - inputImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - inputImageSize.height * scale) / 2;
        //缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        //修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds, scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        //描绘人脸区域
        UIView * faceView = [[UIView alloc]initWithFrame:faceViewBounds];
        faceView.layer.borderWidth = 2;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [_imageView addSubview:faceView];
        
        //判断是否有左眼位置
        if (faceFeature.hasLeftEyePosition) {
            NSLog(@"有左眼啊！");
        }
        if (faceFeature.hasRightEyePosition) {
            NSLog(@"有右眼的位置");
        }
        if (faceFeature.hasMouthPosition) {
            NSLog(@"有嘴巴耶");
        }
    }
}

#pragma mark imagepicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.image = [self compressImageSize:image toByte:1000000];
    if ([self.delegate respondsToSelector:@selector(selectImageTo:)]) {
        [self.delegate selectImageTo:[self compressImageSize:image toByte:1000000]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
   // [self detect:image];
}
//取消回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength {
    UIImage *resultImage = image;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    return resultImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
