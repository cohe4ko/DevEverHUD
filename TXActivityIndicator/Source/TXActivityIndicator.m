//
//  TXActivityIndicator.m
//  TXActivityIndicator
//
//  Created by Ruslan Rezin on 29.04.13.
//  Copyright (c) 2013 Ruslan Rezin. All rights reserved.
//

#import "TXActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#import "UIImage+BBlock.h"

#define kPresentHideAnimationDuration 0.25f
#define kRotationStep 0.1
#define kRotationInterval 0.015

@implementation TXActivityIndicator
@synthesize progress = _progress;
@synthesize buttonClose = _buttonClose;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _imageViewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        [self addSubview:_imageViewBackground];
        
        UIImage *backgroundImage = [UIImage imageForSize:CGSizeMake(72, 72) opaque:NO withDrawingBlock:^{
            [self drawBackgroundImage];
        }];
        
        _imageViewBackground.image = backgroundImage;
        
        CGRect rotationInternalWheelRect = CGRectMake(9, 9, 54, 54);
        
        _imageViewRotationInternalWheel = [[UIImageView alloc] initWithFrame:rotationInternalWheelRect];
        [self addSubview:_imageViewRotationInternalWheel];
        
        _imageViewRotationInternalWheel.image = [UIImage imageWithIdentifier:[NSString stringWithFormat:@"rotationInternalWheel%0.1lf%0.1lf",rotationInternalWheelRect.size.width,rotationInternalWheelRect.size.height] forSize:rotationInternalWheelRect.size andDrawingBlock:^{
            [self drawInternalRotationIndicator:rotationInternalWheelRect.size];
        }];
        
        CGRect rotationExternalWheelRect = CGRectMake(0, 0, 72, 72);
        _imageViewRotationExternalWheel = [[UIImageView alloc] initWithFrame:rotationExternalWheelRect];
        [self addSubview:_imageViewRotationExternalWheel];
        
        _imageViewRotationExternalWheel.image = [UIImage imageWithIdentifier:[NSString stringWithFormat:@"rotationExternalWheel%0.1lf%0.1lf",rotationExternalWheelRect.size.width,rotationExternalWheelRect.size.height] forSize:rotationExternalWheelRect.size andDrawingBlock:^{
            [self drawExternalRotationIndicator:rotationExternalWheelRect.size];
        }];
        
        CGSize buttonCloseSize = CGSizeMake(22, 22);
        _buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonClose.frame = CGRectMake(roundf(frame.size.width/2.0) - roundf(buttonCloseSize.width/2.0), _imageViewBackground.frame.origin.y + roundf(_imageViewBackground.frame.size.width/2.0) - roundf(buttonCloseSize.height/2.0), buttonCloseSize.width, buttonCloseSize.height);
        
        NSString *closeImageID = [NSString stringWithFormat:@"CloseButtonID%0.1lf%0.1lf",buttonCloseSize.width,buttonCloseSize.height];
        UIImage *closeButtonImage = [UIImage imageWithIdentifier:closeImageID forSize:buttonCloseSize andDrawingBlock:^{
            [self drawCloseButtonImageForSize:buttonCloseSize];
        }];
        
        [_buttonClose setImage:closeButtonImage forState:UIControlStateNormal];
        [self addSubview:_buttonClose];
        
        _progress = 0.0;
        
        [self createLayer];
    }
    return self;
}

- (void)dealloc{
    [self stopAnimating];
}

#pragma mark - Interface

- (void)startAnimating{
    _currentRotationAngle = 0.0;
    
    [self stopAnimating];
    
    _imageViewRotationInternalWheel.transform = CGAffineTransformIdentity;
    _imageViewRotationExternalWheel.transform = CGAffineTransformIdentity;
    
    _timerRotation = [NSTimer scheduledTimerWithTimeInterval:kRotationInterval target:self
                                                    selector:@selector(rotate)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopAnimating{
    if (_timerRotation && [_timerRotation isValid]) {
        [_timerRotation invalidate];
        _timerRotation = nil;
    }
}

#pragma mark - Interface

- (void)showOnView:(UIView*)view animated:(BOOL)animated{
    if (view) {
        if (animated) {
            self.alpha = 0.0;
        }
        self.frame = CGRectMake(roundf(view.frame.size.width/2.0-self.frame.size.width/2.0), roundf(view.frame.size.height/2.0 - self.frame.size.height/2.0), self.frame.size.width, self.frame.size.height);
        [view addSubview:self];
        if (animated) {
            [UIView animateWithDuration:kPresentHideAnimationDuration animations:^{
                self.alpha = 1.0;
            }];
        }
    }
}

- (void)hideAnimated:(BOOL)animated{
    if (!animated) {
        [self removeFromSuperview];
    }else{
        [UIView animateWithDuration:kPresentHideAnimationDuration
                         animations:^{
                             self.alpha = 0.0;
                         } completion:^(BOOL finished){
                             [self removeFromSuperview];
                         }];
    }
}

#pragma mark - Layer

- (void)createLayer{
    //Get the scale of the device
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    
    //Calculate the pixels based on scale
    CGSize layerSize = CGSizeMake(self.bounds.size.width*contentScale,self.bounds.size.height*contentScale);
    //Create the layer with the current graphics context
    _layerDisplay = (__bridge CALayer*)CGLayerCreateWithContext(UIGraphicsGetCurrentContext(),layerSize,NULL);
    //Get the resulting layer
    CGContextRef destContext = CGLayerGetContext((__bridge CGLayerRef)_layerDisplay);
    //Scale the layer context to match points
    CGContextScaleCTM(destContext,contentScale,contentScale);
}


#pragma mark - Image

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
}


- (void)drawBackgroundImage{
    //// Color Declarations
    UIColor* color1 = [UIColor colorWithRed: 0.285 green: 0.282 blue: 0.271 alpha: 1];
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 72, 72);
    
    
    //// Group
    {
        //// Circles
        {
            //// Background Drawing
            UIBezierPath* backgroundPath = [UIBezierPath bezierPath];
            [backgroundPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 71.5)];
            [backgroundPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.42, CGRectGetMinY(frame) + 71.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 55.58)];
            [backgroundPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 16.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 16.42, CGRectGetMinY(frame) + 0.5)];
            [backgroundPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 71.5, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 55.58, CGRectGetMinY(frame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 71.5, CGRectGetMinY(frame) + 16.42)];
            [backgroundPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 71.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 71.5, CGRectGetMinY(frame) + 55.58) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 55.58, CGRectGetMinY(frame) + 71.5)];
            [backgroundPath closePath];
            backgroundPath.miterLimit = 4;
            
            [color0 setFill];
            [backgroundPath fill];
            
            
            //// Circle3 Drawing
            UIBezierPath* circle3Path = [UIBezierPath bezierPath];
            [circle3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 1)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 71, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 55.3, CGRectGetMinY(frame) + 1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 71, CGRectGetMinY(frame) + 16.7)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 71) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 71, CGRectGetMinY(frame) + 55.3) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 55.3, CGRectGetMinY(frame) + 71)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 1, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.7, CGRectGetMinY(frame) + 71) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 1, CGRectGetMinY(frame) + 55.3)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 1) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 1, CGRectGetMinY(frame) + 16.7) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 16.7, CGRectGetMinY(frame) + 1)];
            [circle3Path closePath];
            [circle3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame))];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 16.12, CGRectGetMinY(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 16.12)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 72) controlPoint1: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 55.88) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 16.12, CGRectGetMinY(frame) + 72)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 72, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 55.88, CGRectGetMinY(frame) + 72) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 72, CGRectGetMinY(frame) + 55.88)];
            [circle3Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 72, CGRectGetMinY(frame) + 16.12) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 55.88, CGRectGetMinY(frame))];
            [circle3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame))];
            [circle3Path closePath];
            circle3Path.miterLimit = 4;
            
            [color1 setFill];
            [circle3Path fill];
            
            
            //// Circle2 Drawing
            UIBezierPath* circle2Path = [UIBezierPath bezierPath];
            [circle2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 10)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 62, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 50.34, CGRectGetMinY(frame) + 10) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 62, CGRectGetMinY(frame) + 21.66)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 62) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 62, CGRectGetMinY(frame) + 50.34) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 50.34, CGRectGetMinY(frame) + 62)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 10, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 21.66, CGRectGetMinY(frame) + 62) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 10, CGRectGetMinY(frame) + 50.34)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 10) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 10, CGRectGetMinY(frame) + 21.66) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.66, CGRectGetMinY(frame) + 10)];
            [circle2Path closePath];
            [circle2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 9)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 21.09, CGRectGetMinY(frame) + 9) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 21.09)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 63) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 50.91) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 21.09, CGRectGetMinY(frame) + 63)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 50.91, CGRectGetMinY(frame) + 63) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 50.91)];
            [circle2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 9) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 21.09) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 50.91, CGRectGetMinY(frame) + 9)];
            [circle2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 9)];
            [circle2Path closePath];
            circle2Path.miterLimit = 4;
            
            [color1 setFill];
            [circle2Path fill];
            
            
            //// Circle1 Drawing
            UIBezierPath* circle1Path = [UIBezierPath bezierPath];
            [circle1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 19)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 53, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 45.37, CGRectGetMinY(frame) + 19) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 53, CGRectGetMinY(frame) + 26.63)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 53) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 53, CGRectGetMinY(frame) + 45.37) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 45.37, CGRectGetMinY(frame) + 53)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 26.63, CGRectGetMinY(frame) + 53) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 45.37)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 19) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 26.63) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 26.63, CGRectGetMinY(frame) + 19)];
            [circle1Path closePath];
            [circle1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 18)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 18, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 26.06, CGRectGetMinY(frame) + 18) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18, CGRectGetMinY(frame) + 26.06)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 54) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 18, CGRectGetMinY(frame) + 45.94) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 26.06, CGRectGetMinY(frame) + 54)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 54, CGRectGetMinY(frame) + 36) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 45.94, CGRectGetMinY(frame) + 54) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 54, CGRectGetMinY(frame) + 45.94)];
            [circle1Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 18) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 54, CGRectGetMinY(frame) + 26.06) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 45.94, CGRectGetMinY(frame) + 18)];
            [circle1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36, CGRectGetMinY(frame) + 18)];
            [circle1Path closePath];
            circle1Path.miterLimit = 4;
            
            [color1 setFill];
            [circle1Path fill];
        }
    }
   
}

- (void)drawCloseButtonImageForSize:(CGSize)size{
    //// Color Declarations
    UIColor* color1 = [UIColor colorWithRed: 0.285 green: 0.282 blue: 0.271 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.411 green: 0.411 blue: 0.415 alpha: 1];
    
    //// Frames
    CGRect frame2 = CGRectMake(0, 0, size.width, size.height);
    
    
    //// Group
    {
        //// Close Drawing
        UIBezierPath* closePath = [UIBezierPath bezierPath];
        [closePath moveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.68039 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.50000 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.92095 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.25944 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.92095 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.07905 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.97079 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.20964 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.97079 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.12884 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.74056 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.07905 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.87116 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.02921 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.79036 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.02921 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.50000 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.31961 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.25944 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.07905 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.07905 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.07905 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.20964 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.02921 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.12884 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.02921 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.07905 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.25944 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.02921 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.12884 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.02921 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.20964 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.31961 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.50000 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.07905 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.74056 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.07905 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.92095 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.02921 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.79036 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.02921 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.87116 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.25944 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.92095 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.12884 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.97079 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.20964 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.97079 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.50000 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.68039 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.74056 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.92095 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.92095 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.92095 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.79036 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.97079 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.87116 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.97079 * CGRectGetHeight(frame2))];
        [closePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.92095 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.74056 * CGRectGetHeight(frame2)) controlPoint1: CGPointMake(CGRectGetMinX(frame2) + 0.97079 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.87116 * CGRectGetHeight(frame2)) controlPoint2: CGPointMake(CGRectGetMinX(frame2) + 0.97079 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.79036 * CGRectGetHeight(frame2))];
        [closePath addLineToPoint: CGPointMake(CGRectGetMinX(frame2) + 0.68039 * CGRectGetWidth(frame2), CGRectGetMinY(frame2) + 0.50000 * CGRectGetHeight(frame2))];
        [closePath closePath];
        [color2 setFill];
        [closePath fill];
        [color1 setStroke];
        closePath.lineWidth = 1;
        [closePath stroke];
    }
   
}

- (void)drawInternalRotationIndicator:(CGSize)size{
    //// Color Declarations
    UIColor* color1 = [UIColor colorWithRed: 0.285 green: 0.282 blue: 0.271 alpha: 1];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    
    //// Group
    {
        //// Circles
        {
        }
        
        
        //// MoverInternal Drawing
        UIBezierPath* moverInternalPath = [UIBezierPath bezierPath];
        [moverInternalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74878 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74880 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59731 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81254 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68493 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85185 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68490 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81257 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.59730 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85183 * CGRectGetHeight(frame))];
        [moverInternalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49993 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85185 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28365 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77754 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41818 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85183 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.34345 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82419 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20566 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78715 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25946 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75865 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.22455 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76294 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21527 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86513 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18677 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81135 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19107 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84624 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49993 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96296 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.29369 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92641 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39281 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96300 * CGRectGetHeight(frame))];
        [moverInternalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96296 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82736 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82737 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.62764 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96300 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74372 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91106 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.96296 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91105 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74376 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.96300 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62769 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90740 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44444 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96296 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46931 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93807 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44444 * CGRectGetHeight(frame))];
        [moverInternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87673 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44444 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.85184 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46933 * CGRectGetHeight(frame))];
        [moverInternalPath closePath];
        moverInternalPath.miterLimit = 4;
        
        [color1 setFill];
        [moverInternalPath fill];
    }
}

- (void)drawExternalRotationIndicator:(CGSize)size{
    //// Color Declarations
    UIColor* color1 = [UIColor colorWithRed: 0.285 green: 0.282 blue: 0.271 alpha: 1];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    
    //// Group
    {
        //// MoverExternal Drawing
        UIBezierPath* moverExternalPath = [UIBezierPath bezierPath];
        [moverExternalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88889 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77501 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77499 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.88886 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60753 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84543 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70449 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88889 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70451 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84543 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.60754 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88887 * CGRectGetHeight(frame))];
        [moverExternalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88889 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26117 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80697 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40978 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88887 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32715 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85835 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20269 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81424 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24301 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79283 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79608 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87271 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18856 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83239 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19181 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85856 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49999 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97222 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.28989 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93503 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39079 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97225 * CGRectGetHeight(frame))];
        [moverExternalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97222 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83393 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83393 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.63029 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97225 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.74861 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91931 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97222 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91931 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74860 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97225 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63029 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93056 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45833 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97222 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47699 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95356 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45833 * CGRectGetHeight(frame))];
        [moverExternalPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88889 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90756 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45833 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.88889 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47700 * CGRectGetHeight(frame))];
        [moverExternalPath closePath];
        moverExternalPath.miterLimit = 4;
        
        [color1 setFill];
        [moverExternalPath fill];
    }

}

#pragma mark - Private

- (void)rotate{
    _currentRotationAngle += kRotationStep;
    
    if (_currentRotationAngle > 2*M_PI) {
        _currentRotationAngle = _currentRotationAngle - 2*M_PI;
    }
    
    _imageViewRotationInternalWheel.transform = CGAffineTransformMakeRotation(_currentRotationAngle);
    _imageViewRotationExternalWheel.transform = CGAffineTransformMakeRotation(-_currentRotationAngle);
}

@end
