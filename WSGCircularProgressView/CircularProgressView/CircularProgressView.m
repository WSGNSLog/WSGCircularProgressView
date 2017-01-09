//
//  CircularProgressView.m
//  WSGCircularProgressView
//
//  Created by wsg on 2017/1/6.
//  Copyright © 2017年 wsg. All rights reserved.
//

#import "CircularProgressView.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0
#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

@interface CircularProgressViewBackGroundLayer : CALayer

@property (nonatomic, strong) UIColor *tintColor;

@end

@implementation CircularProgressViewBackGroundLayer

- (id)init
{
    self = [super init];
    
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}
- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.tintColor.CGColor);
    
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 1, 1));
    
    CGContextFillRect(ctx, CGRectMake(CGRectGetMidX(self.bounds) - 4, CGRectGetMidY(self.bounds) - 4, 0, 0));
}


@end

@interface CircularProgressView ()

@property (nonatomic, strong) CircularProgressViewBackGroundLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end
@implementation CircularProgressView
{
    UIColor *_progressTintColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    
    _progressTintColor = [UIColor blackColor];
    self.labelbackgroundColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.textFont = [UIFont systemFontOfSize:15];
    // Set up the background layer
    
    CircularProgressViewBackGroundLayer *backgroundLayer = [[CircularProgressViewBackGroundLayer alloc] init];
    backgroundLayer.frame = self.bounds;
    backgroundLayer.tintColor = self.progressTintColor;
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
    // Set up the shape layer
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.progressTintColor.CGColor;
    
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    [self startIndeterminateAnimation];
}
- (void)layoutSubviews{
    [super layoutSubviews];
//    [super addSubview:self.centerLabel];
    self.centerLabel.backgroundColor = self.labelbackgroundColor;
    self.centerLabel.textColor = self.textColor;
    self.centerLabel.font = self.textFont;
    self.centerLabel.text = @"0%";
    [self addSubview:self.centerLabel];
}

- (UILabel *)centerLabel
{
    if(!_centerLabel)
    {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT/2)];
        _centerLabel.center = CGPointMake(WIDTH/2, HEIGHT/2);
        _centerLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _centerLabel;
}
#pragma mark - Accessors

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    _progress = progress;
    
    if (progress > 0) {
        BOOL startingFromIndeterminateState = [self.shapeLayer animationForKey:@"indeterminateAnimation"] != nil;
        
        [self stopIndeterminateAnimation];
        
        self.shapeLayer.lineWidth = 3;
        
        self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                              radius:self.bounds.size.width/2 - 2
                                                          startAngle:3*M_PI_2
                                                            endAngle:3*M_PI_2 + 2*M_PI
                                                           clockwise:YES].CGPath;
        
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = (startingFromIndeterminateState) ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            self.shapeLayer.strokeEnd = progress;
            
            [self.shapeLayer addAnimation:animation forKey:@"animation"];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.shapeLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        // If progress is zero, then add the indeterminate animation
        [self.shapeLayer removeAnimationForKey:@"animation"];
        
        [self startIndeterminateAnimation];
    }
}
- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        [self setValue:progressTintColor forKey:@"tintColor"];
    } else {
        _progressTintColor = progressTintColor;
        [self tintColorDidChange];
    }
}

- (UIColor *)progressTintColor
{
    if ([self respondsToSelector:@selector(tintColor)]) {
        return [self valueForKey:@"tintColor"];
    } else {
        return _progressTintColor;
    }
}

#pragma mark - UIControl overrides

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    // Ignore touches that occur before progress initiates
    
    if (self.progress > 0) {
        [super sendAction:action to:target forEvent:event];
    }
}

#pragma mark - Other methods

- (void)tintColorDidChange
{
    self.backgroundLayer.tintColor = self.progressTintColor;
    self.shapeLayer.strokeColor = self.progressTintColor.CGColor;
}

- (void)startIndeterminateAnimation
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.backgroundLayer.hidden = YES;
    
    self.shapeLayer.lineWidth = 1;
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                                                          radius:self.bounds.size.width/2 - 1
                                                      startAngle:DEGREES_TO_RADIANS(348)
                                                        endAngle:DEGREES_TO_RADIANS(12)
                                                       clockwise:NO].CGPath;
    self.shapeLayer.strokeEnd = 1;
    
    [CATransaction commit];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.shapeLayer addAnimation:rotationAnimation forKey:@"indeterminateAnimation"];
}

- (void)stopIndeterminateAnimation
{
    [self.shapeLayer removeAnimationForKey:@"indeterminateAnimation"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundLayer.hidden = NO;
    [CATransaction commit];
}

@end