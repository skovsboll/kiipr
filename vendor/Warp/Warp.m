//
//  AZWarpView.m
//  DHWarpViewExample
//
//  Created by Alex Gray on 10/10/12.
//  Copyright (c) 2012 Proofe Solutions LLC. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Warp.h"


@implementation Warp
@synthesize baseSize;
@synthesize topLeft, topRight, bottomRight, bottomLeft;


- (void)getGaussianElimination:(CGFloat *)input count:(int)n {
    CGFloat * A = input;
    int i = 0;
    int j = 0;
    int m = n-1;
    while (i < m && j < n){
        int maxi = i;		// Find pivot in column j, starting in row i;
        for(int k = i+1; k<m; k++)	if(fabs(A[k*n+j]) > fabs(A[maxi*n+j])) 		maxi = k;
        if (A[maxi*n+j] != 0){
            //swap rows i and maxi, but do not change the value of i
            if(i!=maxi)  for(int k=0;k<n;k++){ float aux = A[i*n+k]; A[i*n+k]=A[maxi*n+k];  A[maxi*n+k]=aux; }
            //Now A[i,j] will contain the old value of A[maxi,j].  divide each entry in row i by A[i,j]
            float A_ij=A[i*n+j];
            for(int k=0;k<n;k++) A[i*n+k]/=A_ij;
            //Now A[i,j] will have the value 1.
            for(int u = i+1; u< m; u++){
                //subtract A[u,j] * row i from row u
                float A_uj = A[u*n+j];
                for(int k=0;k<n;k++) A[u*n+k]-=A_uj*A[i*n+k];
                //Now A[u,j] will be 0, since A[u,j] - A[i,j] * A[u,j] = A[u,j] - 1 * A[u,j] = 0.
            } i++; } j++; }
    for(int i=m-2;i>=0;i--){				//back substitution

        for(int j=i+1;j<n-1;j++){
            A[i*n+m]-=A[i*n+j]*A[j*n+m];
            //A[i*n+j]=0;
        }
    }
}

- (CATransform3D)homographyMatrixFromSource:(AZWVQuad)src destination:(AZWVQuad)dst {
    CGFloat P[8][9] = {
            {-src.p1.x, -src.p1.y, -1,   0,   0,  0, src.p1.x*dst.p1.x, src.p1.y*dst.p1.x, -dst.p1.x }, // h11
            {  0,   0,  0, -src.p1.x, -src.p1.y, -1, src.p1.x*dst.p1.y, src.p1.y*dst.p1.y, -dst.p1.y }, // h12

            {-src.p2.x, -src.p2.y, -1,   0,   0,  0, src.p2.x*dst.p2.x, src.p2.y*dst.p2.x, -dst.p2.x }, // h13
            {  0,   0,  0, -src.p2.x, -src.p2.y, -1, src.p2.x*dst.p2.y, src.p2.y*dst.p2.y, -dst.p2.y }, // h21

            {-src.p3.x, -src.p3.y, -1,   0,   0,  0, src.p3.x*dst.p3.x, src.p3.y*dst.p3.x, -dst.p3.x }, // h22
            {  0,   0,  0, -src.p3.x, -src.p3.y, -1, src.p3.x*dst.p3.y, src.p3.y*dst.p3.y, -dst.p3.y }, // h23

            {-src.p4.x, -src.p4.y, -1,   0,   0,  0, src.p4.x*dst.p4.x, src.p4.y*dst.p4.x, -dst.p4.x }, // h31
            {  0,   0,  0, -src.p4.x, -src.p4.y, -1, src.p4.x*dst.p4.y, src.p4.y*dst.p4.y, -dst.p4.y }, // h32
    };

    [self getGaussianElimination:&P[0][0] count:9];

    CATransform3D matrix = CATransform3DIdentity;

    matrix.m11 = P[0][8];
    matrix.m21 = P[1][8];
    matrix.m31 = 0;
    matrix.m41 = P[2][8];

    matrix.m12 = P[3][8];
    matrix.m22 = P[4][8];
    matrix.m32 = 0;
    matrix.m42 = P[5][8];

    matrix.m13 = 0;
    matrix.m23 = 0;
    matrix.m33 = 1;
    matrix.m43 = 0;

    matrix.m14 = P[6][8];
    matrix.m24 = P[7][8];
    matrix.m34 = 0;
    matrix.m44 = 1;

    return matrix;
}




//- (void)warp {
//
//    AZWVQuad src;
//    src.p1 = CGPointMake(0, 0);
//    src.p2 = CGPointMake(baseSize.width, 0);
//    src.p3 = CGPointMake(baseSize.width, baseSize.height);
//    src.p4 = CGPointMake(0, baseSize.height);
//
//    AZWVQuad dst;
//    dst.p1 = topLeft;
//    dst.p2 = topRight;
//    dst.p3 = bottomRight;
//    dst.p4 = bottomLeft;
//
//    if (!CGPointEqualToPoint(self.layer.anchorPoint, CGPointMake(0, 0))) {
//        CGRect previousFrame = self.frame;
//        self.layer.anchorPoint = CGPointMake(0, 0);
//        self.frame = previousFrame;
//    }
//
//    self.layer.transform = [self homographyMatrixFromSource:src destination:dst];
//}

- (CATransform3D)quadFromSquare_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {

    float dx1 = x1 - x2,    dy1 = y1 - y2;
    float dx2 = x3 - x2,    dy2 = y3 - y2;
    float sx = x0 - x1 + x2 - x3;
    float sy = y0 - y1 + y2 - y3;
    float g = (sx * dy2 - dx2 * sy) / (dx1 * dy2 - dx2 * dy1);
    float h = (dx1 * sy - sx * dy1) / (dx1 * dy2 - dx2 * dy1);
    float a = x1 - x0 + g * x1;
    float b = x3 - x0 + h * x3;
    float c = x0;
    float d = y1 - y0 + g * y1;
    float e = y3 - y0 + h * y3;
    float f = y0;

    CATransform3D mat;

    mat.m11 = a;
    mat.m12 = b;
    mat.m13 = 0;
    mat.m14 = c;

    mat.m21 = d;
    mat.m22 = e;
    mat.m23 = 0;
    mat.m24 = f;

    mat.m31 = 0;
    mat.m32 = 0;
    mat.m33 = 1;
    mat.m34 = 0;

    mat.m41 = g;
    mat.m42 = h;
    mat.m43 = 0;
    mat.m44 = 1;

    return mat;

}

- (CATransform3D)squareFromQuad_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 {

    CATransform3D mat = [self quadFromSquare_x0:x0 y0:y0 x1:x1 y1:y1 x2:x2 y2:y2 x3:x3 y3:y3];

    // invert through adjoint

    float a = mat.m11,      d = mat.m21,    /* ignore */            g = mat.m41;
    float b = mat.m12,      e = mat.m22,    /* 3rd col*/            h = mat.m42;
    /* ignore 3rd row */
    float c = mat.m14,      f = mat.m24;

    float A =     e - f * h;
    float B = c * h - b;
    float C = b * f - c * e;
    float D = f * g - d;
    float E =     a - c * g;
    float F = c * d - a * f;
    float G = d * h - e * g;
    float H = b * g - a * h;
    float I = a * e - b * d;

    // Probably unnecessary since 'I' is also scaled by the determinant,
    //   and 'I' scales the homogeneous coordinate, which, in turn,
    //   scales the X,Y coordinates.
    // Determinant  =   a * (e - f * h) + b * (f * g - d) + c * (d * h - e * g);
    float idet = 1.0f / (a * A           + b * D           + c * G);

    mat.m11 = A * idet;     mat.m21 = D * idet;     mat.m31 = 0;    mat.m41 = G * idet;
    mat.m12 = B * idet;     mat.m22 = E * idet;     mat.m32 = 0;    mat.m42 = H * idet;
    mat.m13 = 0       ;     mat.m23 = 0       ;     mat.m33 = 1;    mat.m43 = 0       ;
    mat.m14 = C * idet;     mat.m24 = F * idet;     mat.m34 = 0;    mat.m44 = I * idet;

    return mat;

}

@end