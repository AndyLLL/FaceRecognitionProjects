//
//  ViewController.m
//  FaceRecognitionProject
//
//  Created by Andy on 2018/3/8.
//  Copyright © 2018年 AndyLLL. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()<PhotoSelectDelegate>
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.view.frame.size.width/2-30, self.view.frame.size.height/2-15, 60, 30);
    [button setTitle:@"拍照" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-100, 300)];
    [self.view addSubview:_imageView];
}

- (void)pickAction{
    CameraViewController * vc = [[CameraViewController alloc]init];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}
//人脸识别
- (void)detect:(UIImage *)image{
    //图像识别能力：可以在cidetectoreaccuracyhigh（较强的处理能力）与CIDetectorAccuracyLow(较弱的处理能力)中选择
    NSDictionary * opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
    
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
    NSLog(@"识别出了%ld张脸",features.count);
}

- (void)selectImageTo:(UIImage *)image{
    _imageView.image = image;
    [self detect:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
