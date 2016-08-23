//
//  AppColorManager.m
//  CoreVideo
//
//  Created by apple on 15/10/16.
//  Copyright (c) 2015年 yangyu   QQ：623240480. All rights reserved.
//

#import "AppColorManager.h"

@implementation AppColorManager
+(NSColor *)appBackgroundColor{
   NSColor *bgColor=[NSColor colorWithCalibratedRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1.0];
   // [[NSColor blackColor] CGColor];69.74
   //  NSColor *bgColor= [NSColor colorWithPatternImage:[NSImage imageNamed:@"car.png"]];
    return bgColor;
}
@end
