//
//  ViewController.m
//  OffScreenRendering
//
//  Created by 胡彦鹏 on 2021/2/16.
//

#import "ViewController.h"

@interface ViewController () {
    CGFloat _SW;
}

@end

@implementation ViewController

- (void)loadView {
    UIScrollView * view = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = [UIColor systemBackgroundColor];
    view.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1600);
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _SW = UIScreen.mainScreen.bounds.size.width;
    CGFloat w = (_SW-150)/2.f;
    
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
    imgV3.layer.borderColor = UIColor.blackColor.CGColor;
    imgV3.layer.borderWidth = 3.f;
    [self.view addSubview:imgV3];
    
    // 第二行第二个
    // masksToBounds+border+cornerRadius会触发离屏渲染
    UIImageView * imgV4 = [self testImageView];
    imgV4.frame = CGRectMake(100+w, 100+w, w, w);
    imgV4.layer.borderColor = UIColor.blackColor.CGColor;
    imgV4.layer.borderWidth = 3.f;
    imgV4.layer.cornerRadius = 30.f;
    imgV4.layer.masksToBounds = YES;
    [self.view addSubview:imgV4];
    
    // 第三行第一个
    // 普通view圆角不会触发离屏渲染
    UIView * redView = [[UIView alloc] initWithFrame:CGRectMake(50, 150+2*w, w, w)];
    redView.backgroundColor = [UIColor redColor];
    redView.layer.cornerRadius = 30.f;
    redView.layer.masksToBounds = YES;
    [self.view addSubview:redView];
    
    // 第三行第二个
    // 普通view圆角border不会触发离屏渲染,因为不需要masksToBounds
    UIView * greenView = [[UIView alloc] initWithFrame:CGRectMake(100+w, 150+2*w, w, w)];
    greenView.backgroundColor = [UIColor greenColor];
    greenView.layer.cornerRadius = 30.f;
    greenView.layer.borderColor = UIColor.blackColor.CGColor;
    greenView.layer.borderWidth = 3.f;
    [self.view addSubview:greenView];
    
    // 第四行第一个
    // mask触发离屏渲染
    UIView * imgBV5 = [[UIView alloc] initWithFrame:CGRectMake(50, 200+3*w, w, w)];
    imgBV5.backgroundColor = UIColor.redColor;
    CAShapeLayer * shapeMask = [self getRoundShapeLayerWithFrame:CGRectMake(0, 0, w, w)];
    imgBV5.layer.mask = shapeMask;
    [self.view addSubview:imgBV5];
    
    // 第四行第二个
    // addSublayer 不会触发离屏渲染
    UIView * imgBV6 = [[UIView alloc] initWithFrame:CGRectMake(100+w, 200+3*w, w, w)];
    imgBV6.layer.cornerRadius = 30.f;
    imgBV6.backgroundColor = UIColor.greenColor;
    CAGradientLayer * gradientMask = [self getGradualChangingColorWithFrame:imgBV6.bounds fromColor:UIColor.redColor toColor:UIColor.yellowColor];
    gradientMask.cornerRadius = 30.f;
    [imgBV6.layer addSublayer:gradientMask];
    [self.view addSubview:imgBV6];
    
    // 第五行第一个
    // 通过UIGraphics获取截取带圆角的UIImage+绘制边框不会触发离屏渲染
    UIImageView * imgV7 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 250+4*w, w, w)];
    imgV7.layer.cornerRadius = 30.f;
    imgV7.layer.borderColor = UIColor.blackColor.CGColor;
    imgV7.layer.borderWidth = 3.f;
    UIImage * image7 = [UIImage imageNamed:@"福"];
    image7 = [self originImage:image7 scaleToSize:CGSizeMake(w, w)];
    image7 = [self drawCircleImage:image7 cornerRadius:30.f];
    imgV7.image = image7;
    [self.view addSubview:imgV7];
    
    // 第五行第二个
    // 通过复合的方式实现一个带边框的图片不触发离屏渲染
    UIView * imgBV8 = [[UIView alloc] initWithFrame:CGRectMake(100+w, 250+4*w, w, w)];
    imgBV8.backgroundColor = [UIColor greenColor];
    imgBV8.layer.cornerRadius = 30.f;
    imgBV8.layer.borderColor = UIColor.blackColor.CGColor;
    imgBV8.layer.borderWidth = 3.f;
    [self.view addSubview:imgBV8];
    UIImageView * imgV8 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
    imgV8.layer.cornerRadius = 30.f;
    imgV8.layer.masksToBounds = YES;
    UIImage * image8 = [UIImage imageNamed:@"福"];
    imgV8.image = image8;
    [imgBV8 addSubview:imgV8];
    
    /**
     shadow引起离屏渲染的原因:
        shadow应该在所在layer的下方绘制,根据画家算法,下面的图层应该先绘制,但是此时shadow所在的layer还没有绘制,导致矛盾发生.所以系统另外申请了一块内存用于组合layer和其shadow.这就是离屏渲染.
     解决方案是:
        指定shadowPath,使得shadow可以脱离layer进行先绘制,符合了画家算法.不用另外申请内存.
     */
    //第6行第一个,发生了离屏渲染
    UIView * yellowView = [[UIView alloc] initWithFrame:CGRectMake(50, 300+5*w, w, w)];
    yellowView.backgroundColor = UIColor.yellowColor;
    yellowView.layer.borderWidth = 1.f;
    yellowView.layer.borderColor = UIColor.redColor.CGColor;
    yellowView.layer.shadowColor = UIColor.blackColor.CGColor;
    yellowView.layer.shadowOpacity = 0.8f;
    yellowView.layer.shadowOffset = CGSizeMake(0, 0);
    yellowView.layer.shadowRadius = 8.f;
    [self.view addSubview:yellowView];
    
    //第6行第二个,没有离屏渲染
    UIView * purpleView = [[UIView alloc] initWithFrame:CGRectMake(100+w, 300+5*w, w, w)];
    purpleView.backgroundColor = UIColor.purpleColor;
    purpleView.layer.borderWidth = 1.f;
    purpleView.layer.borderColor = UIColor.redColor.CGColor;
    purpleView.layer.shadowColor = UIColor.blackColor.CGColor;
    purpleView.layer.shadowOpacity = 0.8f;
    purpleView.layer.shadowOffset = CGSizeMake(0, 0);
    purpleView.layer.shadowRadius = 8.f;
//    purpleView.layer.cornerRadius = 30.f;
    // 指定shadowPath
    purpleView.layer.shadowPath = [self shadowPathWithView:greenView cornerRadius:purpleView.layer.cornerRadius];
    [self.view addSubview:purpleView];
    
    // 第七行
    // 当一个View拥有SubView,SubLayer. alpha & layer.opacity都会发生离屏渲染
    UIView * v1 = [[UIView alloc] initWithFrame:CGRectMake(50, 350+6*w, w, w)];
    v1.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    [self.view addSubview:v1];
//    v1.alpha = 0.5;
//    v1.layer.opacity = 0.5;
    UIView * v2 = [[UIView alloc] initWithFrame:CGRectMake(w/2, w/2, w, w)];
    v2.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
//    [v1 addSubview:v2];
    [v1.layer addSublayer:v2.layer];
//    UIView * v3 = [[UIView alloc] initWithFrame:CGRectMake(50+w/2, 350+6*w+w/2, w, w)];
//    v3.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
//    [self.view addSubview:v3];
    
    // 毛玻璃
    // 毛玻璃必然会触发离屏渲染
    UIImage * img9 = [UIImage imageNamed:@"blur"];
    UIImageView * imgV9 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 450+7*w, _SW-100, img9.size.height/img9.size.width*(_SW-100))];
    imgV9.contentMode = UIViewContentModeScaleAspectFill;
    imgV9.image = img9;
    [self.view addSubview:imgV9];
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = CGRectMake(imgV9.bounds.size.width/2, 0, imgV9.bounds.size.width/2, imgV9.bounds.size.height);
    [imgV9 addSubview:effectView];
    // 这个可以去除黑白模式,但是不是所有毛玻璃效果都可以这么处理
    effectView.subviews.lastObject.backgroundColor = nil;
}

- (UIImageView *)testImageView {
    UIImageView * imgV = [[UIImageView alloc] init];
    imgV.image = [UIImage imageNamed:@"福"];
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

- (CAGradientLayer *)getGradualChangingColorWithFrame:(CGRect)frame fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    return gradientLayer;
}

- (CAShapeLayer *)getRoundShapeLayerWithFrame:(CGRect)frame {
    CAShapeLayer * mask = [CAShapeLayer new];
    CGFloat w = frame.size.width;
    mask.opacity = 1.0;
    mask.path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:w/2].CGPath;
    return mask;
}

- (CGPathRef)shadowPathWithView:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-0, -0, view.bounds.size.width, view.bounds.size.height) cornerRadius:cornerRadius];
    return path.CGPath;
}

-(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size {
    CGFloat scale = UIScreen.mainScreen.scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

@end
