//
//  ViewController3.m
//  OffScreenRendering
//
//  Created by ICBC_App_2 on 2020/12/15.
//

#import "ViewController3.h"
#import "ViewController4.h"

@interface ViewController3 ()

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"阴影";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"混合颜色" style:UIBarButtonItemStylePlain target:self action:@selector(groupOpacityPage)];
    
    /**
     shadow引起离屏渲染的原因:
        shadow应该在所在layer的下方绘制,根据画家算法,下面的图层应该先绘制,但是此时shadow所在的layer还没有绘制,导致矛盾发生.所以系统另外申请了一块内存用于组合layer和其shadow.这就是离屏渲染.
     解决方案是:
        指定shadowPath,使得shadow可以脱离layer进行先绘制,符合了画家算法.不用另外申请内存.
     */
    //第一行,发生了离屏渲染
    CGFloat w = (UIScreen.mainScreen.bounds.size.width-150)/2.f;
    UIView * greenView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, w, w)];
    greenView.backgroundColor = UIColor.greenColor;
    greenView.layer.borderWidth = 1.f;
    greenView.layer.borderColor = UIColor.redColor.CGColor;
    greenView.layer.shadowColor = UIColor.blackColor.CGColor;
    greenView.layer.shadowOpacity = 0.8f;
    greenView.layer.shadowOffset = CGSizeMake(0, 0);
    greenView.layer.shadowRadius = 5.f;
    [self.view addSubview:greenView];
    
    //第二行,没有离屏渲染
    UIView * purpleView = [[UIView alloc] initWithFrame:CGRectMake(50, 100+w, w, w)];
    purpleView.backgroundColor = UIColor.purpleColor;
    purpleView.layer.borderWidth = 1.f;
    purpleView.layer.borderColor = UIColor.redColor.CGColor;
    purpleView.layer.shadowColor = UIColor.blackColor.CGColor;
    purpleView.layer.shadowOpacity = 0.8f;
    purpleView.layer.shadowOffset = CGSizeMake(0, 0);
    purpleView.layer.shadowRadius = 5.f;
    // 指定shadowPath
    purpleView.layer.shadowPath = [self shadowPathWithView:greenView shadowWidth:5.f cornerRadius:5.f];
    [self.view addSubview:purpleView];
}

- (CGPathRef)shadowPathWithView:(UIView *)view shadowWidth:(CGFloat)shadowWidth cornerRadius:(CGFloat)cornerRadius {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-shadowWidth, -shadowWidth, view.bounds.size.width+shadowWidth*2, view.bounds.size.height+shadowWidth*2) cornerRadius:cornerRadius];
    return path.CGPath;
}

- (void)groupOpacityPage {
    ViewController4 * v4 = [ViewController4 new];
    [self.navigationController pushViewController:v4 animated:YES];
}

@end
