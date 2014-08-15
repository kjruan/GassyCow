//
//  DebugDraw.m
//  GassyCow
//
//  Created by Kevin Ruan on 8/14/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "DebugDraw.h"

static BOOL kDebugDraw = YES;

@implementation SKSpriteNode (DebugDraw)

-(void)attachDebugFrameFromPath:(CGPathRef)bodyPath
{
    if (kDebugDraw == NO) return;
    
    SKShapeNode *shape = [SKShapeNode node];
    
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    
    shape.lineWidth = 1.0;
    
    [self addChild:shape];
}

-(void)attachDebugRectWithSize:(CGSize)s
{
    CGPathRef bodyPath = CGPathCreateWithRect(CGRectMake(-s.width/2, -s.height/2, s.width, s.height), nil);
    
    [self attachDebugFrameFromPath:bodyPath];
    CGPathRelease(bodyPath);
    
}

@end
