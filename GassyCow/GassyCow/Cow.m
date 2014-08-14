//
//  cow.m
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "Cow.h"

@implementation Cow

+(SKTexture *)generateTexture {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        SKSpriteNode *cow = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Cow2"]];
        SKView *textureView = [SKView new];
        texture = [textureView textureFromNode:cow];
    });
    return texture;
}

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"cowSprite";
        
    }
    return self;
}

-(SKAction *)walking {
    // All parameters hardcoded. The idea is to randomize all the options
    SKAction *wait = [SKAction waitForDuration:5];
    SKAction *wonderLeft = [SKAction sequence:@[[SKAction scaleXTo:self.xScale * -1 duration:0],[SKAction moveByX:15 y:0 duration:5]]];
    SKAction *wonderRight = [SKAction sequence:@[[SKAction scaleXTo:self.xScale duration:0],[SKAction moveByX:-15 y:0 duration:5]]];
    //[self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wonderLeft, wait, wonderRight]]] withKey:@"walking"];
    
    SKAction *actionGroup = [SKAction sequence:@[wonderLeft, wait, wonderRight]];
    return actionGroup;
}

-(void)fly {
    // Flying means taking off gravity. 
    self.physicsBody.affectedByGravity = NO;
    [[self physicsBody] applyForce:CGVectorMake(5.0, 1.0) atPoint:CGPointMake(0.0, 0.0)];
}

-(void)update:(CFTimeInterval)delta {
    
}



@end
