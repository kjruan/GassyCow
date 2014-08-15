//
//  DebugDraw.h
//  GassyCow
//
//  Created by Kevin Ruan on 8/14/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)
-(void)attachDebugRectWithSize:(CGSize)s;
-(void)attachDebugFrameFromPath:(CGPathRef)bodyPath;
@end
