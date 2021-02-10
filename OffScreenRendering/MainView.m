//
//  MainView.m
//  OffScreenRendering
//
//  Created by ICBC_App_2 on 2020/12/14.
//

#import "MainView.h"

@implementation MainView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.systemBackgroundColor;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    NSLog(@"%@",NSStringFromCGRect(rect));
    //回次render会丢弃上一次的context
    if (num == 0) {
        //第一步:获取上下文
        //CGContextRef 用来保存图形信息.输出目标
        CGContextRef context = UIGraphicsGetCurrentContext();
        //第二步:画图形
        //设置线的颜色
        CGContextSetRGBStrokeColor(context, 255/255.0, 0/255.0, 0/255.0, 1);
        //设置线的宽度
        CGContextSetLineWidth(context, 13);
        //设置连接点得样式
        CGContextSetLineJoin(context, kCGLineJoinRound);
        //设置线头尾的样式
        CGContextSetLineCap(context, kCGLineCapRound);
        //起点
        CGContextMoveToPoint(context, 20, 20);
        //画线
        CGContextAddLineToPoint(context, 100, 100);
        CGContextAddLineToPoint(context, 100, 150);
        //第三步:渲染到视图上
        CGContextStrokePath(context);
        num++;
    } else {
        //第一步:获取上下文
        //CGContextRef 用来保存图形信息.输出目标
        CGContextRef context = UIGraphicsGetCurrentContext();
        //第二步:画图形
        //设置线的颜色
        CGContextSetRGBStrokeColor(context, 255/255.0, 0/255.0, 0/255.0, 1);
        //设置线的宽度
        CGContextSetLineWidth(context, 13);
        //设置连接点得样式
        CGContextSetLineJoin(context, kCGLineJoinRound);
        //设置线头尾的样式
        CGContextSetLineCap(context, kCGLineCapRound);
        //起点
        CGContextMoveToPoint(context, 100, 150);
        //画线
        CGContextAddLineToPoint(context, 200, 200);
        CGContextAddLineToPoint(context, 400, 350);
        //第三步:渲染到视图上
        CGContextStrokePath(context);
    }
}

@end
