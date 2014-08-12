//
//  Entity.h
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Entity : SKSpriteNode
@property (assign,nonatomic) CGPoint direction;

+(SKTexture *)generateTexture;
- (instancetype)initWithPosition:(CGPoint)position;
- (void)update:(CFTimeInterval)delta;

@end
