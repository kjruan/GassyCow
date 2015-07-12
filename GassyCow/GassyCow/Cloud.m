//
//  Cloud.m
//  GassyCow
//
//  Created by Kevin Ruan on 4/27/15.
//  Copyright (c) 2015 Kevin Ruan. All rights reserved.
//

#import "Cloud.h"

#define ARC4RANDOM_MAX  0x100000000

static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

@implementation Cloud
{
    SKAction* _cloudAnimation;
    CGVector _leftMoveVector;
    CGVector _rightMoveVector;
}

+(SKTexture *)generateTexture {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat temp = ScalarRandomRange(1, 3);
        int rand = (int) roundf(temp);
        SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:[NSString stringWithFormat:@"cloud%i.png", rand]]];
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:cloud];
    });
    return texture;
}

-(SKNode *)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"cloud";
        self.texture = [Cloud generateTexture];
        self.position = position;
        
        CGFloat direction = ScalarRandomRange(10.0, 60.0);
        CGFloat magnitude = ScalarRandomRange(1.0, 3.0);
        _leftMoveVector = CGVectorMake(direction, magnitude);
        _rightMoveVector = CGVectorMake(direction * -1, magnitude * -1);
    }
    return self;
}

-(SKAction *)moveCloud
{
    SKAction* moveLeft = [SKAction moveBy:_leftMoveVector duration:5.0];
    SKAction* moveRight = [SKAction moveBy:_rightMoveVector duration:5.0];
    SKAction* pause = [SKAction waitForDuration:1.0];
    SKAction *actionGroup = [SKAction repeatActionForever:[SKAction sequence:@[moveLeft, pause, moveRight, pause]]];
    return actionGroup;
}

-(CGVector)travelVector:(CGFloat)zRotation
{
    CGVector v = CGVectorMake(0.5, 0.1);
    return v;
}

@end
