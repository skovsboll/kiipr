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

@end