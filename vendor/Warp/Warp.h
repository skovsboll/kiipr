//
//  AZWarpView.h
//  DHWarpViewExample
//
//  Created by Alex Gray on 10/10/12.
//  Copyright (c) 2012 Proofe Solutions LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


typedef struct
{
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    CGPoint p4;
} AZWVQuad;


@interface Warp : NSObject

@property (nonatomic, assign) CGSize baseSize;
@property (nonatomic, assign) CGPoint topLeft, topRight, bottomRight, bottomLeft;

- (CATransform3D)homographyMatrixFromSource:(AZWVQuad)src destination:(AZWVQuad)dst;


- (CATransform3D)quadFromSquare_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3;
- (CATransform3D)squareFromQuad_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3;

@end