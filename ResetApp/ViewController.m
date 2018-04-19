//
//  ViewController.m
//  ResetApp
//
//  Created by Blavtes on 2018/4/17.
//  Copyright © 2018年 Blavtes. All rights reserved.
//

#import "ViewController.h"
#import "PointView.h"
#import "LineInfo.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *poingtArray;
@property (nonatomic, strong) NSMutableArray *lineArray;

@property (nonatomic, strong) PointView *movePoint;

@end
static float kWidth = 20;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _poingtArray = [NSMutableArray arrayWithCapacity:1];
    _lineArray = [NSMutableArray arrayWithCapacity:1];
    [self initPointArrLevel:6];
    // Do any additional setup after loading the view, typically from a nib.
}

- (CGPoint)randomPoint
{
    CGPoint point = CGPointMake(kWidth, kWidth);
    point.x = MAX(arc4random() % ((int)[UIScreen mainScreen].bounds.size.width - 20), (arc4random() % 5 + 1) * 20);
    point.y = MAX(arc4random() % ((int)[UIScreen mainScreen].bounds.size.height - 30), (arc4random() % 5 + 1) * 50);
    NSLog(@"x, y %f,%f",point.x, point.y);
    return point;
}

- (void)initPointArrLevel:(int)level
{
    int pointCount = 6 + level;
    int lineCount = pointCount + level + 1;
    for (int i = 0; i < pointCount; i++) {
        PointView *pointView = [PointView new];
        pointView.backgroundColor = [UIColor blackColor];
        pointView.layer.cornerRadius = kWidth / 2;
        pointView.layer.masksToBounds = YES;
        pointView.flag = i;
        pointView.text.text = [NSString stringWithFormat:@"%d",i];
        pointView.frame = CGRectMake(0, 0, kWidth, kWidth);
        pointView.center = [self randomPoint];
        
        [_poingtArray addObject:pointView];
        pointView.layer.zPosition  = 12;
        [self.view.layer addSublayer:pointView.layer];
    }
    
    for (int i = 1; i < _poingtArray.count ; i++) {
        LineInfo *line = [LineInfo new];
        line.startView = _poingtArray[i - 1];
        line.endView = _poingtArray[i];
        [line.path moveToPoint:line.startView.center];
        [line.path addLineToPoint:line.endView.center];
        line.lineLayer.path = line.path.CGPath;
        line.lineLayer.zPosition  = 10;

        [self.view.layer addSublayer:line.lineLayer];
        [_lineArray addObject:line];
    }
    
    for (NSInteger i = (lineCount - _poingtArray.count - 1); i < lineCount; i++) {
        int index1 = rand() % _poingtArray.count;
        int index2 = rand() % _poingtArray.count;
        if (index1 == index2) {
            i--;
            continue;
        }
        LineInfo *line = [LineInfo new];
        line.startView = _poingtArray[index1];
        line.endView = _poingtArray[index2];
        [line.path moveToPoint:line.startView.center];
        [line.path addLineToPoint:line.endView.center];
        line.lineLayer.path = line.path.CGPath;
        line.lineLayer.zPosition  = 10;
        BOOL fillter = NO;
        for (int j = 0; j < _lineArray.count; j++) {
            LineInfo *tmp = _lineArray[j];
            if ([tmp isEqual:line]) {
                fillter = YES;
                i++;
                break;
            }
        }
        if (!fillter) {
            [self.view.layer addSublayer:line.lineLayer];
            [_lineArray addObject:line];
        }
     
    }
    [self checkoutLineColor];

//    NSLog(@"point %@",_poingtArray);
}

- (BOOL)judgeLineIntersectWithOne:(LineInfo *)lineOne  two:(LineInfo *)two
{
    
    return [self segmentsIntersectWithOne:lineOne two:two];
}

- (int)dblcmpA:(double)a B:(double)b
{
    if (fabs(a-b) <= 1e-6) {
        return 0;
    }
    if (a > b) {
        return 1;
    }
    return -1;
}

//***************点积判点是否在线段上***************
- (double)dot:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2
{
    return x1 * x2 + y1 * y2;
}

//求a点是不是在线段bc上，>0不在，=0与端点重合，<0在。
- (int)pointOnLinePoint:(CGPoint)a pointB:(CGPoint)b pointC:(CGPoint)c
{
    return [self dblcmpA:[self dot:b.x-a.x y1:b.y-a.y x2:c.x-a.x y2:c.y-a.y] B:0];
}

- (double)crossX1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2
{
    return x1*y2 - x2*y1;
}
//ab与ac的叉积
- (double)abCrossAc:(CGPoint)a pointB:(CGPoint)b pointC:(CGPoint)c
{
    return [self crossX1:b.x - a.x y1:b.y-a.y x2:c.x - a.x y2:c.y -a.y];
}

//求ab是否与cd相交，交点为p。1规范相交，0交点是一线段的端点，-1不相交。
- (BOOL)abCosscd:(CGPoint)a pointB:(CGPoint)b pointC:(CGPoint)c pointD:(CGPoint)d
{
    double s1 = 0;
    double s2 = 0;
    double s3 = 0;
    double s4 = 0;
    int d1 = 0;
    int d2 = 0;
    int d3 = 0;
    int d4 = 0;
    CGPoint p = CGPointZero;
    s1 = [self abCrossAc:a pointB:b pointC:c];
    s2 = [self abCrossAc:a pointB:b pointC:d];
    s3 = [self abCrossAc:c pointB:d pointC:a];
    s4 = [self abCrossAc:c pointB:d pointC:b];
    d1 = [self dblcmpA:s1 B:0];
    d2 = [self dblcmpA:s2 B:0];
    d3 = [self dblcmpA:s3 B:0];
    d4 = [self dblcmpA:s4 B:0];
    
    //如果规范相交则求交点
    if ((d1^d2)==-2 && (d3^d4)==-2)
    {
        p.x=(c.x*s2-d.x*s1)/(s2-s1);
        p.y=(c.y*s2-d.y*s1)/(s2-s1);
//        NSLog(@"交点 %f %f",p.x,p.y);
        return YES;
    }
    //交点为端点
    if (d1 == 0 && [self pointOnLinePoint:c pointB:a pointC:b] <= 0) {
        p = c;
        
    } else if (d2 == 0 && [self pointOnLinePoint:d pointB:a pointC:b] <= 0) {
        p = d;
        
    } else if (d3 == 0 && [self pointOnLinePoint:a pointB:c pointC:d] <= 0) {
        p = a;
        
    } else if (d4 == 0 && [self pointOnLinePoint:b pointB:c pointC:d] <= 0) {
        p = b;
        
    }
//    -1不相交
    return NO;
}

#pragma mark ------------ 判断两条直线是否相交
- (BOOL)segmentsIntersectWithOne:(LineInfo *)lineOne  two:(LineInfo *)two
{
    return [self abCosscd:lineOne.startView.center pointB:lineOne.endView.center pointC:two.startView.center pointD:two.endView.center];
}

//找到触摸的点
- (PointView *)findPoint:(CGPoint)point
{
    PointView *findView  = nil;
    CGPoint pointLine = point;
    for (PointView *view in _poingtArray) {
        pointLine = [view.layer convertPoint:point fromLayer:self.view.layer]; //get layer using containsPoint:
        
        if ([view.layer containsPoint:pointLine]) {
            findView = view;
            break;
        }
    }
    return findView;
}

//改变相交线的位置颜色
- (void)changeLine
{
    for (LineInfo *info in _lineArray) {
        if (info.startView.flag == _movePoint.flag) {
            [info.path removeAllPoints];
            
            [info.path moveToPoint:info.startView.center];
            [info.path addLineToPoint:info.endView.center];
            info.lineLayer.path = info.path.CGPath;
            info.lineLayer.zPosition = 10;
            [self.view.layer addSublayer:info.lineLayer];
            
        } else if (info.endView.flag == _movePoint.flag) {
            [info.path removeAllPoints];
            
            [info.path moveToPoint:info.startView.center];
            [info.path addLineToPoint:info.endView.center];
            info.lineLayer.path = info.path.CGPath;
             info.lineLayer.zPosition = 10;
            [self.view.layer addSublayer:info.lineLayer];

        }
    }
     [self checkoutLineColor];
}

//改变相交线的颜色
- (void)checkoutLineColor
{
    for (int i = 0; i < _lineArray.count; i++) {
        LineInfo *start = _lineArray[i];
        BOOL judge = NO;
        for (int j = 0; j < _lineArray.count; j++) {
            if (i == j) {
                continue;
            }
            
            LineInfo *end = _lineArray[j];
            if ([self judgeLineIntersectWithOne:start two:end]) {
                
                judge = YES;
            }
        }
        if (judge) {
            start.lineLayer.strokeColor = [UIColor blackColor].CGColor;
            NSLog(@"flog %d",start.startView.flag);
        } else {
            start.lineLayer.strokeColor = [UIColor greenColor].CGColor;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    PointView *view = [self findPoint:point];
//    NSLog(@"touchesBegan %@",view);
    _movePoint = view;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    point.x = MIN(MAX(10, point.x), [UIScreen mainScreen].bounds.size.width - 10);
    point.y = MIN(MAX(30, point.y), [UIScreen mainScreen].bounds.size.height - 10);
    _movePoint.center = point;
    [self changeLine];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    point.x = MIN(MAX(10, point.x), [UIScreen mainScreen].bounds.size.width - 10);
    point.y = MIN(MAX(30, point.y), [UIScreen mainScreen].bounds.size.height - 10);
    _movePoint.center = point;
    [self changeLine];
    
//    NSLog(@"touchesEnded");
    _movePoint = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
