//
//  cow.m
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "cow.h"

@implementation cow

+(SKTexture *)generateTexture {
    SKTexture *texture = nil;
    texture = [SKTexture textureWithImageNamed:@"cow2"];
    return texture;
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"cowSprite";
    }
    return self;
}

-(void)cowWonder {
    SKAction *wait = [SKAction waitForDuration:5];
    SKAction *wonderLeft = [SKAction sequence:@[[SKAction scaleXTo:self.xScale * -1 duration:0],[SKAction moveByX:15 y:0 duration:5]]];
    SKAction *wonderRight = [SKAction sequence:@[[SKAction scaleXTo:self.xScale duration:0],[SKAction moveByX:-15 y:0 duration:5]]];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wonderLeft, wait, wonderRight]]] withKey:@"cowWonder"];
}

-(void)cowFloat {
    self.physicsBody.affectedByGravity = NO;
    [[self physicsBody] applyForce:CGVectorMake(0.5, 0.01) atPoint:CGPointMake(0.0, 0.0)];
}

-(void)update:(CFTimeInterval)delta {
    
}



@end
