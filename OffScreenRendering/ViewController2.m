//
//  ViewController2.m
//  OffScreenRendering
//
//  Created by ICBC_App_2 on 2020/12/14.
//

#import "ViewController2.h"
#import "ViewController3.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)loadView {
    UIScrollView * view = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = [UIColor systemBackgroundColor];
    view.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1000);
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"阴影" style:UIBarButtonItemStylePlain target:self action:@selector(shadowPage)];
    
    _SW = UIScreen.mainScreen.bounds.size.width;
    CGFloat w = (_SW-150)/2.f;
    
    self.title = @"圆角";
    
    // 第一行第一个
    // 当圆角位于最上层,即使cornerRadius+masksToBounds,也不会触发离屏渲染
    UIImageView * imgV = [self testImageView];
    imgV.frame = CGRectMake(50, 50, w, w);
    imgV.layer.cornerRadius = 30.f;
    imgV.layer.masksToBounds = YES;
    [self.view addSubview:imgV];
    
    // 第一行第二个
    // 当圆角不在最上层,触发离屏渲染
    UIView * imgBV = [[UIView alloc] initWithFrame:CGRectMake(100+w, 50, w, w)];
    imgBV.layer.cornerRadius = 30.f;
    imgBV.layer.masksToBounds = YES;
    [self.view addSubview:imgBV];
    UIImageView * imgV2 = [self testImageView];
    imgV2.frame = CGRectMake(0, 0, w, w);
    [imgBV addSubview:imgV2];
        
    // 第二行第一个
    // 单独的border不会触发离屏渲染
    UIImageView * imgV3 = [self testImageView];
    imgV3.frame = CGRectMake(50, 100+w, w, w);
    imgV3.layer.borderColor = UIColor.redColor.CGColor;
    imgV3.layer.borderWidth = 3.f;
    [self.view addSubview:imgV3];
    
    // 第二行第二个
    // masksToBounds+border会触发离屏渲染
    UIImageView * imgV4 = [self testImageView];
    imgV4.frame = CGRectMake(100+w, 100+w, w, w);
    imgV4.layer.borderColor = UIColor.redColor.CGColor;
    imgV4.layer.borderWidth = 3.f;
    imgV4.layer.cornerRadius = 30.f;
    imgV4.layer.masksToBounds = YES;//注释这行理解masksToBounds的意思
    [self.view addSubview:imgV4];
    
    // 第三行第一个
    // 普通view圆角不会触发离屏渲染,因为不需要masksToBounds
    UIView * redView = [[UIView alloc] initWithFrame:CGRectMake(50, 150+2*w, w, w)];
    redView.backgroundColor = [UIColor redColor];
    redView.layer.cornerRadius = 30.f;
    [self.view addSubview:redView];
    
    // 第三行第二个
    // 普通view圆角border不会触发离屏渲染,因为不需要masksToBounds
    UIView * greenView = [[UIView alloc] initWithFrame:CGRectMake(100+w, 150+2*w, w, w)];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.layer.cornerRadius = 30.f;
    greenView.layer.borderColor = UIColor.redColor.CGColor;
    greenView.layer.borderWidth = 3.f;
    [self.view addSubview:greenView];
    
    // 第四行第一个
    // mask触发离屏渲染
    UIView * imgBV5 = [[UIView alloc] initWithFrame:CGRectMake(50, 200+3*w, w, w)];
    imgBV5.backgroundColor = UIColor.grayColor;
    CAShapeLayer * mask = [CAShapeLayer new];
    mask.opacity = 1.0;
    mask.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, w) cornerRadius:30.f].CGPath;
    imgBV5.layer.mask = mask;
    [self.view addSubview:imgBV5];
    
    // 第四行第二个
    // 圆角+边框不触发离屏渲染方案
    // UIView的圆角和边框不会触发离屏渲染
    // 图片的圆角不会触发离屏渲染
    CGFloat borderWidth6 = 3.f;
    CGFloat cornerRadius6 = 30.f;
    UIView * borderV6 = [[UIView alloc] initWithFrame:CGRectMake(100+w, 200+3*w, w, w)];
    borderV6.layer.cornerRadius = cornerRadius6;
    borderV6.layer.borderColor = UIColor.redColor.CGColor;
    borderV6.layer.borderWidth = borderWidth6;
    [self.view addSubview:borderV6];
    UIImageView * imgV6 = [self testImageView];
    imgV6.frame = CGRectMake(borderWidth6, borderWidth6, w-borderWidth6*2, w-borderWidth6*2);
    imgV6.layer.cornerRadius = cornerRadius6-borderWidth6;
    imgV6.layer.masksToBounds = YES;//注释这行理解masksToBounds的意思
    [borderV6 addSubview:imgV6];
    
    // 第五行第一个
    // 通过UIGraphics获取截取带圆角的UIImage+绘制边框不会触发离屏渲染
    UIImageView * imgV7 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 250+4*w, w, w)];
    imgV7.layer.cornerRadius = 30.f;
    imgV7.layer.borderColor = UIColor.redColor.CGColor;
    imgV7.layer.borderWidth = 3.f;
    UIImage * image7 = [UIImage imageNamed:@"吃饭时间表"];
    image7 = [self originImage:image7 scaleToSize:CGSizeMake(w, w)];
    image7 = [self drawCircleImage:image7 cornerRadius:30.f];
    imgV7.image = image7;
    [self.view addSubview:imgV7];
}

- (UIImageView *)testImageView {
    UIImageView * imgV = [[UIImageView alloc] init];
    imgV.image = [UIImage imageNamed:@"吃饭时间表"];
    return imgV;
}

- (UIImage *)drawCircleImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius {
    CGFloat side = MIN(image.size.width, image.size.height);
    CGFloat scale = UIScreen.mainScreen.scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), NO, scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, side, side) cornerRadius:cornerRadius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    CGFloat marginX = (image.size.width - side) * 0.5;
    CGFloat marginY = (image.size.height - side) * 0.5;
    [image drawInRect:CGRectMake(marginX, marginY, side, side)];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size {
    CGFloat scale = UIScreen.mainScreen.scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

- (void)shadowPage {
    ViewController3 * v3 = [ViewController3 new];
    [self.navigationController pushViewController:v3 animated:YES];
}

@end
