#import "AOBezierView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AOBezierView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
    float lastScale;
    float lastRotation;
    float cColor;
    float cWidth;
    int selected;
    CGPoint lastPoint;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self ustaw];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self ustaw];
    }
    return self;
}

- (void)ustaw {
    lastScale = 100.0;
    lastRotation = 0.0;
    cWidth = 2;
    _lines = [NSMutableArray array];
    selected = -1;
}

- (void)drawRect:(CGRect)rect
{
    for (NSArray *arr in _lines) {
        UIBezierPath *cPath = [arr objectAtIndex:0];
        if([_lines indexOfObject:arr] == selected) {
            UIBezierPath *pathCopy = [cPath copy];
            CGPathRef cgPathSelectionRect = CGPathCreateCopyByStrokingPath(pathCopy.CGPath, NULL, pathCopy.lineWidth, pathCopy.lineCapStyle, pathCopy.lineJoinStyle, pathCopy.miterLimit);
            UIBezierPath *selectionRect = [UIBezierPath bezierPathWithCGPath:cgPathSelectionRect];
            //CGPathRelease(cgPathSelectionRect);
            [selectionRect setLineWidth:2];
            
            CGFloat dashStyle[] = { 5.0f, 5.0f };
            [selectionRect setLineDash:dashStyle count:2 phase:0];
            [[UIColor blackColor] setStroke];
            [selectionRect stroke];
        }
        [cPath setLineWidth:[[arr objectAtIndex:2] floatValue]];
        [[UIColor colorWithRed:[[arr objectAtIndex:1] floatValue]/255 green:0 blue:0 alpha:1] setStroke];
        [cPath stroke];
    }
    
    [path setLineWidth:cWidth];
    [[UIColor colorWithRed:cColor/255 green:0 blue:0 alpha:1] setStroke];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    selected = [self hitTest:[touch locationInView:self]];
    
    lastPoint = [touch locationInView:self];
    
    if (selected==-1) {
        ctr = 0;
        UITouch *touch = [touches anyObject];
        pts[0] = [touch locationInView:self];
        
        path = [UIBezierPath bezierPath];
        [path setLineWidth:cWidth];
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if (selected==-1) {
        ctr++;
        pts[ctr] = p;
        if (ctr == 4) 
        {
            pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
            [path moveToPoint:pts[0]];
            [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
            
            [self setNeedsDisplay];
            // replace points and get ready to handle the next segment
            pts[0] = pts[3]; 
            pts[1] = pts[4]; 
            ctr = 1;
        }
    } else {
        UIBezierPath *toMove = [[_lines objectAtIndex:selected] objectAtIndex:0];
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(p.x-lastPoint.x, p.y-lastPoint.y);
        CGPathRef intermediatePath2 = CGPathCreateCopyByTransformingPath(toMove.CGPath, &transform2);
        toMove.CGPath = intermediatePath2;
        [self setNeedsDisplay];
        lastPoint = p;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (path != nil) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:path];
        [arr addObject:[NSNumber numberWithFloat:cColor]];
        [arr addObject:[NSNumber numberWithFloat:cWidth]];
        [_lines addObject:arr];
        path = nil;
        selected = [_lines count]-1;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (NSUInteger)hitTest:(CGPoint)point
{
    /*
    __block NSUInteger hitShapeIndex = -1;
    [_lines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id arr, NSUInteger idx, BOOL *stop) {
        if (CGPathContainsPoint([[arr objectAtIndex:0] CGPath], nil, point, YES)) {
            hitShapeIndex = idx;
            *stop = YES;
        }
    }];
    */
    NSUInteger hitShapeIndex = -1;
    for (NSArray *arr in _lines) {
        UIBezierPath *pat = [arr objectAtIndex:0];
        CGPathRef cgPathSelectionRect = CGPathCreateCopyByStrokingPath(pat.CGPath, NULL, pat.lineWidth, pat.lineCapStyle, pat.lineJoinStyle, pat.miterLimit);
        if (CGPathContainsPoint(cgPathSelectionRect, nil, point, YES)) {
            hitShapeIndex = [_lines indexOfObject:arr];
        }
        pat = nil;
    }
    
    NSLog(@"%d", hitShapeIndex);
    return hitShapeIndex;
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)setLineWidth:(float)num {
    cWidth = num;
    if (selected<0) return;
    [[_lines objectAtIndex:selected] setObject:[NSNumber numberWithFloat:cWidth] atIndex:2];
    [self setNeedsDisplay];
}

- (void)setColor:(float)red {
    cColor = red;
    if (selected<0) return;
    [[_lines objectAtIndex:selected] setObject:[NSNumber numberWithFloat:cColor] atIndex:1];
    [self setNeedsDisplay];
}

- (void)setScale:(float)scale {
    if (selected<0) return;
    
    float newSize = 100*scale;
    float oldSize = lastScale;
    float scaleToValue = newSize/oldSize;
    
    UIBezierPath *cpath = [self getSelected];
    
    CGRect bounds = CGPathGetBoundingBox(cpath.CGPath);
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleToValue, scaleToValue);
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(cpath.CGPath, &transform);
    cpath.CGPath = intermediatePath;
    
    CGRect bounds2 = CGPathGetBoundingBox(cpath.CGPath);
    CGPoint center2 = CGPointMake(CGRectGetMidX(bounds2), CGRectGetMidY(bounds2));
    
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation(center.x-center2.x, center.y-center2.y);
    CGPathRef intermediatePath2 = CGPathCreateCopyByTransformingPath(cpath.CGPath, &transform2);
    cpath.CGPath = intermediatePath2;
    
    lastScale = newSize;
    [self setNeedsDisplay];
}

- (void)setRotation:(float)rotation {
    if (selected<0) return;
    
    float newAngle = rotation;
    float oldAngle = lastRotation;
    float rotationValue = newAngle-oldAngle;
    //NSLog(@"%f", rotationValue);
    
    UIBezierPath *cpath = [self getSelected];
    
    CGRect bounds = CGPathGetBoundingBox(cpath.CGPath);
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotationValue*5*M_1_PI/180);
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(cpath.CGPath, &transform);
    cpath.CGPath = intermediatePath;
    
    CGRect bounds2 = CGPathGetBoundingBox(cpath.CGPath);
    CGPoint center2 = CGPointMake(CGRectGetMidX(bounds2), CGRectGetMidY(bounds2));
    
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation(center.x-center2.x, center.y-center2.y);
    CGPathRef intermediatePath2 = CGPathCreateCopyByTransformingPath(cpath.CGPath, &transform2);
    cpath.CGPath = intermediatePath2;
    
    lastRotation = newAngle;
    [self setNeedsDisplay];
}

- (UIBezierPath *)getSelected {
    return [[_lines objectAtIndex:selected] objectAtIndex:0];
}

- (void)deleteSelectedPath {
    if(selected>=0) {
        [_lines removeObjectAtIndex:selected];
        [self setNeedsDisplay];
        selected=-1;
    }
}

@end


