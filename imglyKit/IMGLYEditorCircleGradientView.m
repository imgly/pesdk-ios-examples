//
//  IMGLYEditorCircleGradientView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 07.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorCircleGradientView.h"

#import "IMGLYDefaultEditorImageProvider.h"

#import "UIImage+IMGLYKitAdditions.h"

// pi is approximately equal to 3.14159265359.
#define   DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

@interface IMGLYEditorCircleGradientView()

@property (nonatomic, strong) UIImageView *crossImageView;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

@end

@implementation IMGLYEditorCircleGradientView
#pragma mark - init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [self commonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    _imageProvider = imageProvider;
    [self commonInit];
    return self;
}


- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    
    [self commonInit];
    return self;
}

- (void)commonInit {
    if(_crossImageView) // we may run into this metho twice, since super class calls another init too.
        return;
    if(self.imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    }
    self.backgroundColor = [UIColor clearColor];
    [self configureControlPoints];
    [self configureCrossImageView];
    [self configurePanGestureRecognizer];
    [self configurePinchGestureRecognizer];
}

- (void)configureControlPoints {
    _controllPoint1 = CGPointMake(100,100);
    _controllPoint2 = CGPointMake(150,200);
    [self calculateCenterPointFromOtherControlPoints];
}

- (void)configureCrossImageView {
    _crossImageView = [[UIImageView alloc] initWithImage:
                       [_imageProvider focusAnchorImage]];
    [self addSubview:_crossImageView];
}

- (void)configurePanGestureRecognizer {
    _crossImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
    [_crossImageView addGestureRecognizer:panGestureRecognizer];
}

- (void)configurePinchGestureRecognizer {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
}

# pragma mark - vector calculations
- (CGFloat)diagonalLengthOfFrame {
    return sqrtf( self.frame.size.width * self.frame.size.width +
                 self.frame.size.height * self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    // Create an oval shape to draw.
    UIBezierPath *aPath =[UIBezierPath bezierPathWithArcCenter:self.centerPoint
                                                        radius:[self distanceBetweenControlPoints] * 0.5
                                                    startAngle:0
                                                      endAngle:M_PI * 2.0
                                                     clockwise:YES];
    [[UIColor colorWithWhite:0.8 alpha:1.0] setStroke];
   
    [aPath closePath];
    
    //CGSize myShadowOffset = CGSizeMake (-2,  2);
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    
    // If you have content to draw after the shape,
    // save the current state before changing the transform.
    CGContextSaveGState(aRef);
    
    //CGContextSetShadowWithColor (aRef, myShadowOffset, 5, [UIColor blackColor].CGColor);
    // Adjust the drawing options as needed.
    aPath.lineWidth = 1;
    
    // Fill the path before stroking it so that the fill
    // color does not obscure the stroked line.
    [aPath stroke];
    
    // Restore the graphics state before drawing any other content.
    CGContextRestoreGState(aRef);
}

- (void)calculateCenterPointFromOtherControlPoints {
    self.centerPoint = CGPointMake((self.controllPoint1.x + self.controllPoint2.x) / 2.0,
                                   (self.controllPoint1.y + self.controllPoint2.y) / 2.0);
}

#pragma mark - tools
- (CGFloat)distanceBetweenControlPoints {
    CGFloat diffX = self.controllPoint2.x - self.controllPoint1.x;
    CGFloat diffY = self.controllPoint2.y - self.controllPoint1.y;
    
    return sqrtf(diffX * diffX + diffY  * diffY);
}

#pragma mark - gesture handling
- (void)informDeletageAboutRecognizerStates:(UIGestureRecognizer *) recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        if(self.gradientViewDelegate) {
            [self.gradientViewDelegate userInteractionStarted];
        }
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded ||
       recognizer.state == UIGestureRecognizerStateCancelled) {
        if(self.gradientViewDelegate) {
            [self.gradientViewDelegate userInteractionEnded];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *) recognizer {
    CGPoint location = [recognizer locationInView:self];
    [self informDeletageAboutRecognizerStates:recognizer];
    
    CGFloat diffX = location.x - self.centerPoint.x;
    CGFloat diffY = location.y - self.centerPoint.y;
    
    self.controllPoint1 = CGPointMake(self.controllPoint1.x + diffX,
                                      self.controllPoint1.y + diffY);
    self.controllPoint2 = CGPointMake(self.controllPoint2.x + diffX,
                                      self.controllPoint2.y + diffY);
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *) recognizer {
    [self informDeletageAboutRecognizerStates:recognizer];
    if(recognizer.numberOfTouches > 1) {
        self.controllPoint1 = [recognizer locationOfTouch:0 inView:self];
        self.controllPoint2 = [recognizer locationOfTouch:1 inView:self];
    }
}

- (void)setControllPoint1:(CGPoint)controllPoint1 {
    _controllPoint1 = controllPoint1;
}

- (void)setControllPoint2:(CGPoint)controllPoint2 {
    _controllPoint2 = controllPoint2;
    [self calculateCenterPointFromOtherControlPoints];
    [self layoutCrosshair];
    [self setNeedsDisplay];
    if(self.gradientViewDelegate != nil) {
        [self.gradientViewDelegate controlPointChanged];
    }
}

#pragma mark - layouting
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutCrosshair];
    [self setNeedsDisplay];
}

- (void) layoutCrosshair {
    self.crossImageView.center = self.centerPoint;
}
@end
