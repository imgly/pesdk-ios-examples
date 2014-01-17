//
//  IMGLYEditorBoxGradientView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 06.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYDefaultEditorImageProvider.h"
#import "IMGLYEditorBoxGradientView.h"
#import "UIImage+IMGLYKitAdditions.h"

struct IMGLYLine {
    CGPoint start;
    CGPoint end;
};

typedef struct IMGLYLine IMGLYLine;

static const CGFloat kCrossSize = 3.0;
static const CGFloat kTouchZoneSize = 44;

@interface IMGLYEditorBoxGradientView()

@property (nonatomic, assign) IMGLYLine line1;
@property (nonatomic, assign) IMGLYLine line2;
@property (nonatomic, strong) UIImageView *crossImageView;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

@end

@implementation IMGLYEditorBoxGradientView

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
    return self;
}

- (void)commonInit {
    if(_crossImageView) // we may run into this metho twice, since super class calls another init too.
        return;
    if (_imageProvider == nil) {
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

- (CGPoint)normalizedOrtogonalVector {
    CGFloat diffX = self.controllPoint2.x - self.controllPoint1.x;
    CGFloat diffY = self.controllPoint2.y - self.controllPoint1.y;
    
    CGFloat diffLength = sqrtf(diffX * diffX + diffY  * diffY);
    
    return CGPointMake(- diffY / diffLength, diffX / diffLength);
}

/*
 This method appears a bit tricky, but its not.
 We just take the vector that connects the control points,
 and rotate it by 90 degrees. Then we normalize it and give it a total 
 lenghts that is the lenght of the diagonal, of the Frame.
 That diagonal is the longest line that can be drawn in the Frame, therefore its a good orientation.
 */
- (IMGLYLine)lineForControlPoint1 {
    CGPoint normalizedOrtogonalVector = [self normalizedOrtogonalVector];
    CGFloat halfDiagonalLengthOfFrame = [self diagonalLengthOfFrame];
    CGPoint scaledOrthogonalVector = CGPointMake(halfDiagonalLengthOfFrame * normalizedOrtogonalVector.x,
                                                 halfDiagonalLengthOfFrame * normalizedOrtogonalVector.y);
    CGPoint lineStart = CGPointMake(self.controllPoint1.x - scaledOrthogonalVector.x,
                                  self.controllPoint1.y - scaledOrthogonalVector.y);
    CGPoint lineEnd = CGPointMake(self.controllPoint1.x + scaledOrthogonalVector.x,
                                  self.controllPoint1.y + scaledOrthogonalVector.y);
    return IMGLYLineMakeFromPoints(lineStart, lineEnd);
}

- (IMGLYLine)lineForControlPoint2 {
    CGPoint normalizedOrtogonalVector = [self normalizedOrtogonalVector];
    CGFloat halfDiagonalLengthOfFrame = [self diagonalLengthOfFrame];
    CGPoint scaledOrthogonalVector = CGPointMake(halfDiagonalLengthOfFrame * normalizedOrtogonalVector.x,
                                                 halfDiagonalLengthOfFrame * normalizedOrtogonalVector.y);
    CGPoint lineStart = CGPointMake(self.controllPoint2.x - scaledOrthogonalVector.x,
                                    self.controllPoint2.y - scaledOrthogonalVector.y);
    CGPoint lineEnd = CGPointMake(self.controllPoint2.x + scaledOrthogonalVector.x,
                                  self.controllPoint2.y + scaledOrthogonalVector.y);
    return IMGLYLineMakeFromPoints(lineStart, lineEnd);
}

- (void)addLineForControlPoint1ToPath:(UIBezierPath *)path {
    IMGLYLine line = [self lineForControlPoint1];
    [path moveToPoint:line.start];
    [path addLineToPoint:line.end];
}

- (void)addLineForControlPoint2ToPath:(UIBezierPath *)path {
    IMGLYLine line = [self lineForControlPoint2];
    [path moveToPoint:line.start];
    [path addLineToPoint:line.end];
}

/*
 paint an X on the center point
 */
- (void)addLinesForCenterPointToPath:(UIBezierPath *)path {
    IMGLYLine line1 = IMGLYLineMakeFromCoordinates(self.centerPoint.x - kCrossSize,
                                                   self.centerPoint.y - kCrossSize,
                                                   self.centerPoint.x + kCrossSize,
                                                   self.centerPoint.y + kCrossSize);
    IMGLYLine line2 = IMGLYLineMakeFromCoordinates(self.centerPoint.x - kCrossSize,
                                                   self.centerPoint.y + kCrossSize,
                                                   self.centerPoint.x + kCrossSize,
                                                   self.centerPoint.y - kCrossSize);
    [path moveToPoint:line1.start];
    [path addLineToPoint:line1.end];
    [path moveToPoint:line2.start];
    [path addLineToPoint:line2.end];
}

- (void)drawRect:(CGRect)rect {
    // Create an oval shape to draw.
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the render colors.
    [[UIColor colorWithWhite:0.8 alpha:1.0] setStroke];
    [[UIColor redColor] setFill];
    [self addLineForControlPoint1ToPath:aPath];
    [self addLineForControlPoint2ToPath:aPath];
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
    [aPath fill];
    [aPath stroke];
    
    // Restore the graphics state before drawing any other content.
    CGContextRestoreGState(aRef);
}

#pragma mark - line creation helpers
IMGLYLine IMGLYLineMakeFromPoints(CGPoint start, CGPoint end) {
    IMGLYLine line;
    line.start = start;
    line.end = end;
    return line;
}

IMGLYLine IMGLYLineMakeFromCoordinates(CGFloat startX, CGFloat startY, CGFloat endX, CGFloat endY) {
    IMGLYLine line;
    line.start = CGPointMake(startX, startY);
    line.end = CGPointMake(endX, endY);
    return line;
}

- (void)calculateCenterPointFromOtherControlPoints {
    self.centerPoint = CGPointMake((self.controllPoint1.x + self.controllPoint2.x) / 2.0,
                               (self.controllPoint1.y + self.controllPoint2.y) / 2.0);
}

#pragma mark - tools
- (BOOL)isPoint:(CGPoint)point inRect:(CGRect)rect {
    CGFloat top = rect.origin.y;
    CGFloat bottom = top + rect.size.height;
    CGFloat left = rect.origin.x;
    CGFloat right = left + rect.size.width;
    
    BOOL inRectXAxis = point.x > left && point.x < right;
    BOOL inRectYAxis = point.y > top && point.y < bottom;
    return (inRectXAxis && inRectYAxis);
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
    if(recognizer.numberOfTouches > 1)
    {
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
}

- (void) layoutCrosshair {
    self.crossImageView.center = self.centerPoint;
}

@end
