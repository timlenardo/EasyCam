//
//  VideoProgressRing.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VideoProgressRing.h"

@interface VideoProgressRing() {
    CGFloat _ringWidth;
    CGFloat _increment;
    
    CGFloat _maxLength;
    CGFloat _currentLength;
    double _startTime;
    
    NSTimer *_animationTimer;
}
@end

@implementation VideoProgressRing

- (instancetype) initWithFrame:(CGRect)frame withRingWidth:(CGFloat)ringWidth withMaxLength:(CGFloat)maxLength withIncrement:(CGFloat)increment {
    self = [super initWithFrame:frame];
    
    _ringWidth = ringWidth;
    _increment = increment;
    _maxLength = maxLength;
    _currentLength = 0;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGFloat lineWidth = 5;
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = center.x - lineWidth * 0.5;
    CGFloat startAngle = -((float)M_PI / 2);
    
    double percentage = _currentLength / _maxLength;
    CGFloat currentAngle = startAngle + percentage * (2 * ((float)M_PI));
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, currentAngle, 0);
    CGContextStrokePath(context);
}

- (void)startAnimation {
    // TODO implement this sheeeit
    _startTime = [[NSDate date] timeIntervalSince1970];
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updateRing) userInfo:nil repeats:YES];
}

- (void)updateRing {
    double currentTime = [[NSDate date] timeIntervalSince1970];
    double diff = currentTime - _startTime;
    _currentLength = diff;
    
    if (_currentLength > _maxLength) {
        [self stopAnimation];
    } else {
        [self setNeedsDisplay];
    }
}

- (void)stopAnimation {
    [self reset];
}

- (void)reset {
    [_animationTimer invalidate];
    _currentLength = 0;
    _startTime = 0;
    [self setNeedsDisplay];
}

@end
