//
//  cow.m
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "Cow.h"
#define ARC4RANDOM_MAX  0x100000000

@implementation Cow {
    BOOL isFlying;
    NSDictionary *_cowChar;
    NSInteger _FaceMod;
    NSInteger _LeftMod;
    NSInteger _RightMod;
    NSInteger _ChangeMod;
}

static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

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

-(SKNode *)initWithPosition:(CGPoint)position
{
    if (self = [super initWithPosition:position]) {
        self.name = @"cow";
        self.texture = [Cow generateTexture];
        self.position = position;
        CGSize contactSize = CGSizeMake(self.size.width/2, self.size.height/2);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        
        isFlying = NO;
        
        _cowChar = [self cowCharacteristics];
        
        /*
         Right face > 0
         left facing mod = 1
         walk left = negative = -1
         walk right = positive = 1
         */
        if ([[_cowChar valueForKey:@"Facing"] integerValue] > 0) {
            _FaceMod = -1; // Face Right
            _LeftMod = 1;
            _RightMod = -1;
            _ChangeMod = 1;
        } else {
            _FaceMod = 1; // Face Left
            _LeftMod = -1;
            _RightMod = 1;
            _ChangeMod = -1;
        }

        //[self addChild:[self fartEmitter:[[_cowChar valueForKey:@"Facing"] integerValue]]];
    }
    return self;
}


-(SKAction *)walk {
    // Walking animation
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    SKTexture *cowIdel = [atlas textureNamed:@"Cow1"];
    
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

    
    SKAction *wait = [SKAction sequence:@[
                                          stopAnimation,
                                          [SKAction setTexture:cowIdel],
                                          [SKAction waitForDuration:[[_cowChar valueForKey:@"WaitTime"] doubleValue]],
                                          ]];
    SKAction *wonderLeft = [SKAction sequence:@[
                                                [SKAction scaleXTo:self.xScale * _FaceMod duration:0],
                                                [SKAction runBlock:^{
                                                    [self startAnimation:textures];
                                                }],
                                                [SKAction moveByX:[[_cowChar valueForKey:@"MoveLeft"] doubleValue] * _LeftMod y:0 duration:1]
                                                ]];
    SKAction *wonderRight = [SKAction sequence:@[
                                                 [SKAction scaleXTo:self.xScale * _ChangeMod duration:0],
                                                 [SKAction runBlock:^{
                                                    [self startAnimation:textures];
                                                }],
                                                 [SKAction moveByX:[[_cowChar valueForKey:@"MoveRight"] doubleValue] * _RightMod y:0 duration:1]
                                                ]];
    
    SKAction *actionGroup = [SKAction repeatAction:[SKAction sequence:@[wonderLeft, wait, wonderRight, wait]] count:[[_cowChar valueForKey:@"Repeats"] integerValue]];
    return actionGroup;
}

-(void)startAnimation:(NSMutableArray *)textures
{
    SKAction *startAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
    [self runAction:[SKAction repeatActionForever:startAnimation] withKey:@"walkingAnimation"];
}

-(NSDictionary *)cowCharacteristics
{
    
    
    NSDictionary *cowChar = [[NSDictionary alloc] init];

    cowChar = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)ScalarRandomRange(1, 15) % 2], @"Facing",
                                                         [NSNumber numberWithDouble:(double)ScalarRandomRange(1, 15)], @"MoveLeft",
                                                         [NSNumber numberWithDouble:(double)ScalarRandomRange(1, 15)], @"MoveRight",
                                                         [NSNumber numberWithInt:(int)ScalarRandomRange(1, 3)], @"Repeats",
                                                         [NSNumber numberWithDouble:(double)ScalarRandomRange(1, 8)], @"WaitTime", nil];
    
    
    NSLog(@"%@", cowChar);
    return cowChar;
}

-(void)startFartEmitter:(CGFloat)direction
{
    SKEmitterNode *fartEmitter =
    [NSKeyedUnarchiver unarchiveObjectWithFile:
     [[NSBundle mainBundle] pathForResource:@"fart"
                                     ofType:@"sks"]];
    fartEmitter.position = CGPointMake(20, -4);
    fartEmitter.name = @"fartEmitter";
    
    fartEmitter.emissionAngle = direction;
    
    [self addChild:fartEmitter];
}


-(void)fly {
    // Flying means taking off gravity.
    self.physicsBody.affectedByGravity = NO;
    [[self physicsBody] applyImpulse:CGVectorMake(0.0, 1.2) atPoint:CGPointMake(self.position.x - 5.0,self.position.y)];
    self.physicsBody.allowsRotation = NO;
    isFlying = YES;
}

-(CGVector)travelVector:(CGFloat)zRotation
{
    // Depending on direction of the launch... 180 spin = PI, additional spin > 180 = NEG PI.
    // When cow launches facing left, PI < 0 as the cow spins clockwise.
    CGVector v = CGVectorMake(0, 0);
    
    if (!isFlying)
        v = CGVectorMake(0, 0);
    else if (([[_cowChar valueForKey:@"Facing"] integerValue] > 0)) {
        if (zRotation > 0 && zRotation < M_PI / 2)
            v = CGVectorMake(-10, -10);
        else if (zRotation > M_PI / 2 && zRotation < M_PI)
            v = CGVectorMake(10, -10);
        else if (zRotation > -M_PI && zRotation < -M_PI / 2)
            v = CGVectorMake(10, 10);
        else
            v = CGVectorMake(-10, 10);
    } else {
        if (zRotation > 0 && zRotation < M_PI / 2)
            v = CGVectorMake(10, 10);
        else if (zRotation > M_PI / 2 && zRotation < M_PI)
            v = CGVectorMake(-10, 10);
        else if (zRotation > -M_PI && zRotation < -M_PI / 2)
            v = CGVectorMake(-10, -10);
        else
            v = CGVectorMake(10, -10);
    }

    //NSLog(@"Vector dx: %f, dy: %f", v.dx, v.dy);
    //NSLog(@"M_PI value: %f", M_PI);
    
    return v;
}

-(void)update:(CFTimeInterval)delta {

}



@end
