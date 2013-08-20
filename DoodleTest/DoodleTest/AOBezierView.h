//
//  AOBezierView
//
//  Created by sznur
//

#import <UIKit/UIKit.h>

@interface AOBezierView : UIView

@property (nonatomic,strong) NSMutableArray *lines;

- (void)setLineWidth:(float)num;
- (void)setScale:(float)scale;
- (void)setRotation:(float)rotation;
- (void)setColor:(float)red;
- (void)deleteSelectedPath;

@end
