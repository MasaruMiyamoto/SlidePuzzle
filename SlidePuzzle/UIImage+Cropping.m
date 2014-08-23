//
//  UIImage+Cropping.m
//  SlidePuzzle
//
//  Created by PhysLab on 2014/07/25.
//  Copyright (c) 2014年 miyamoto. All rights reserved.
//

#import "UIImage+Cropping.h"

@implementation UIImage (Cropping)
-(UIImage *)croppedImageInRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}
@end
