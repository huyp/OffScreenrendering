//
//  ViewController4.m
//  OffScreenRendering
//
//  Created by ICBC_App_2 on 2020/12/15.
//

#import "ViewController4.h"

@interface ViewController4 ()

@end

@implementation ViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"混合颜色";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    CGFloat w = (UIScreen.mainScreen.bounds.size.width-100);
    
    
    UIView * v1 = [[UIView alloc] initWithFrame:CGRectMake(50, 100, w, w)];
    v1.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    [self.view addSubview:v1];
    
    UIView * v2 = [[UIView alloc] initWithFrame:CGRectMake(0, -50, w, w/2)];
    v2.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    [v1 addSubview:v2];
    
// opaque = NO 不会触发离屏渲染, alpha < 1.0 or layer.opacity < 1.0 会触发离屏渲染, 0 不触发离屏渲染.
//    v2.opaque = NO;
//    v1.alpha = 1.0;
//    v1.layer.opacity = 0.7;
    
    // 正常一个View是不会触发离屏渲染的,如果需要透明,设置颜色alpha的值.不要设置view的属性alpha和layer的属性opacity
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 150+w, w, 100)];
    [btn setTitle:@"按钮" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];
    [self.view addSubview:btn];

}

@end
