//
//  QQBubbleButton.m
//  QQBubbleButton
//
//  Created by 夏明伟 on 2016/12/8.
//  Copyright © 2016年 夏明伟. All rights reserved.
//

#import "QQBubbleButton.h"

#define KButtonWidth self.bounds.size.width
#define KButtonHeight self.bounds.size.height

@interface QQBubbleButton ()

@property (nonatomic ,strong)CAShapeLayer *shapeLayer;

@end

@implementation QQBubbleButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
    }
    
    return self;
}
#pragma mark else from nib
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUpSubviews];
}

#pragma mark 懒加载
- (NSMutableArray *)images{
    if (_images ==nil) {
        _images = [NSMutableArray array];
        for (int i=1; i<9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
            [_images addObject:image];
        }
    }
    return _images;
}
- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        
        /** fillColor 填充色 */
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
        
    }
    return _shapeLayer;
}

- (UIView *)smallCircleView{
    if (!_smallCircleView) {
        _smallCircleView = [[UIView alloc]init];
        _smallCircleView.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:_smallCircleView belowSubview:self];
    }
    return _smallCircleView;
}
#pragma mark setup
- (void)setUpSubviews{
    CGFloat cornerRadius = (KButtonWidth > KButtonHeight ? KButtonHeight / 2.0 : KButtonWidth /2.0);
    
    _maxDistance = cornerRadius *4;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    
    CGRect smallCirclViewRect = CGRectMake(0, 0, cornerRadius * (2- 0.5), cornerRadius * (2- 0.5));
    self.smallCircleView.bounds = smallCirclViewRect;
    self.smallCircleView.center = self.center;
    _smallCircleView.layer.masksToBounds = YES;
    _smallCircleView.layer.cornerRadius = _smallCircleView.bounds.size.width /2.0;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    [self.layer removeAnimationForKey:@"shake"];
    CGPoint panPoint = [pan translationInView:self];
    CGPoint changePointCenter = self.center;
    
    changePointCenter.x += panPoint.x;
    changePointCenter.y += panPoint.y;
    self.center = changePointCenter;
    [pan setTranslation:CGPointZero inView:self];
    
    CGFloat d = [self pointToPointDistanceWithPointA:self.center pointB:self.smallCircleView.center];
    
    if (d < _maxDistance) {
        CGFloat cornerRadius = (KButtonWidth > KButtonHeight ? KButtonHeight / 2.0 : KButtonWidth /2.0);
        CGFloat smallCornerRadius = cornerRadius - d/10;
        _smallCircleView.bounds = CGRectMake(0, 0, smallCornerRadius *(2-0.5), smallCornerRadius *(2-0.5));
        _smallCircleView.layer.cornerRadius = _smallCircleView.bounds.size.width/2.0;
        
        if (d>0 && _smallCircleView.hidden == NO) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:_smallCircleView].CGPath;
        }
    }else{
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        self.smallCircleView.hidden = YES;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (d >_maxDistance) {
            [self startDestoryAnimation];
            [self killAll];
        }else{
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = _smallCircleView.center;
            } completion:^(BOOL finished) {
                self.smallCircleView.hidden = NO;
            }];
        }
    }
}
- (void)killAll
{
    [self removeFromSuperview];
    [self.smallCircleView removeFromSuperview];
    self.smallCircleView = nil;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}
#pragma Mark 两个圆中心点的距离
- (CGFloat )pointToPointDistanceWithPointA:(CGPoint)pointA pointB:(CGPoint )pointB{
    CGFloat offsetX = pointA.x - pointB.x;
    CGFloat offsetY = pointA.y - pointB.y;
    return sqrtf(offsetX *offsetX + offsetY *offsetY);
}
#pragma Mark 画不规则矩形 http://ww3.sinaimg.cn/mw690/0068uRu1gw1etgs1ssj09j30yg0qmaed.jpg (思路分析图)
- (UIBezierPath *)pathWithBigCircleView:(UIView *)bigCircleView smallCircleView:(UIView *)smallCircleView{
    CGFloat x2 = bigCircleView.center.x;
    CGFloat y2 = bigCircleView.center.y;
    CGFloat r2 = bigCircleView.bounds.size.width /2.0;
    
    CGFloat x1 = smallCircleView.center.x;
    CGFloat y1 = smallCircleView.center.y;
    CGFloat r1 = smallCircleView.bounds.size.width/2.0;
    
    CGFloat d = [self pointToPointDistanceWithPointA:bigCircleView.center pointB:smallCircleView.center];
    CGFloat sinθ =  (x2 - x1)/d;
    CGFloat cosθ = (y2 - y1)/d;
    
    CGPoint pointA = CGPointMake(x1- r1 *cosθ, y1 + r1 *sinθ);
    CGPoint pointB = CGPointMake(x1 +r1 *cosθ, y1- r1 *sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //A
    [path moveToPoint:pointA];
    //AB
    [path addLineToPoint:pointB];
    //BC 曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    //cd
    [path addLineToPoint:pointD];
    // dA 曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
    
    
}

#pragma mark 消失动画
- (void)startDestoryAnimation{
    UIImageView *ImageView = [[UIImageView alloc]initWithFrame:self.frame];
    ImageView.animationImages = self.images;
    ImageView.animationRepeatCount = 1;
    ImageView.animationDuration = 0.5;
    [ImageView startAnimating];
    [self.superview addSubview:ImageView];
    
}
- (void)btnClick:(UIButton *)sender{
    [self startDestoryAnimation];
    [self killAll];
}

- (void)setHighlighted:(BOOL)highlighted{
    [self.layer removeAnimationForKey:@"shake"];
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    //左右晃动的幅度大小
    CGFloat shake = (self.bounds.size.width/50)*10;
    keyAnim.values = @[@(-shake),@(shake),@(-shake)];
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = MAXFLOAT;
    keyAnim.duration = 0.3;
    
    [self.layer addAnimation:keyAnim forKey:@"shake"];
    
}
@end
