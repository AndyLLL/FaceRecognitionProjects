//
//  CameraViewController.h
//  FaceRecognitionProject
//
//  Created by Andy on 2018/3/8.
//  Copyright © 2018年 AndyLLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoSelectDelegate <NSObject>
- (void)selectImageTo:(UIImage *)image;
@end

@interface CameraViewController : UIViewController
@property (nonatomic, weak) id<PhotoSelectDelegate> delegate;
@end
