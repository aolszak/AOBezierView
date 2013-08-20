//
//  AOBezierView
//
//  Created by sznur
//

#import "DoodleViewController.h"
#import "AOBezierView.h"

@interface DoodleViewController ()

@property (weak, nonatomic) IBOutlet UISlider *slide;
@property (weak, nonatomic) IBOutlet UISlider *slideAngle;
@property (weak, nonatomic) IBOutlet AOBezierView *bezi;
@property (weak, nonatomic) IBOutlet UISlider *slideScale;
@property (weak, nonatomic) IBOutlet UISlider *slideColor;

@end

@implementation DoodleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _slide.continuous = YES;
    _slideAngle.continuous = YES;
    _slideScale.continuous = YES;
    _slideColor.continuous = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeWidth:(UISlider *)sender {
    [_bezi setLineWidth:sender.value];
}

- (IBAction)changeAngle:(UISlider *)sender {
    [_bezi setRotation:sender.value];
}

- (IBAction)changeScale:(UISlider *)sender {
    [_bezi setScale:sender.value];
}

- (IBAction)changeColor:(UISlider *)sender {
    [_bezi setColor:sender.value];
}

- (IBAction)del:(id)sender {
    [_bezi deleteSelectedPath];
}

@end
