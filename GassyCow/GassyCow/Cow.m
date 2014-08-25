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
        SKSpriteNode *cow = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Cow1"]];
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

-(SKAction *)walk {
    // Walking animation
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    SKTexture *cowIdel = [atlas textureNamed:@"Cow2"];    
    
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:6];
    for (int i = 1; i < 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"Cow%d", i];
        SKTexture *texture = [atlas textureNamed:textureName];
        [textures addObject:texture];
    }
    
    for (int i = 2; i > 1; i--) {
        NSString *textureName = [NSString stringWithFormat:@"Cow%d", i];
        SKTexture *texture = [atlas textureNamed:textureName];
        [textures addObject:texture];
    }
    
    // All parameters hardcoded. The idea is to randomize all the options in the future
    SKAction *stopAnimation = [SKAction runBlock:^{
        [SKAction setTexture:cowIdel];
        [self removeActionForKey:@"walkingAnimation"];
    }];
    
    SKAction *wait = [SKAction sequence:@[stopAnimation, [SKAction waitForDuration:1.0]]];
    SKAction *wonderLeft = [SKAction sequence:@[[SKAction scaleXTo:self.xScale * -1 duration:0], [SKAction runBlock:^{
        [self startAnimation:textures];
    }] ,[SKAction moveByX:15 y:0 duration:2]]];
    SKAction *wonderRight = [SKAction sequence:@[[SKAction scaleXTo:self.xScale duration:0], [SKAction runBlock:^{
        [self startAnimation:textures];
    }]  ,[SKAction moveByX:-15 y:0 duration:1]]];
    SKAction *actionGroup = [SKAction sequence:@[wonderLeft, wait, wonderRight]];
    return actionGroup;
}

-(void)startAnimation:(NSMutableArray *)textures
{
    SKAction *startAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
    [self runAction:[SKAction repeatActionForever:startAnimation] withKey:@"walkingAnimation"];
}


-(void)fly {
    // Flying means taking off gravity.
    self.physicsBody.affectedByGravity = NO;
    [[self physicsBody] applyForce:CGVectorMake(0.0, 1.2) atPoint:CGPointMake(0.0, 0.0)];
    
}


-(void)update:(CFTimeInterval)delta {
    
}



@end
