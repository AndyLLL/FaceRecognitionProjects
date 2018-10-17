# FaceRecognitionProject
iOS基于OC的面部检测Demo，使用iOS自带的CoreImage框架。
# CoreImage
CoreImage是iOS中的图像处理框架，使用上比较简单方便，常用于照片的滤镜处理，还有就是面部检测等用途。
# 工作流程
首页->相机/相册控制器->拍照/选择照片->回调->面部检测（眼睛、鼻子、嘴巴）。
# 使用方法
选择完相片后执行面部检测操作：

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

