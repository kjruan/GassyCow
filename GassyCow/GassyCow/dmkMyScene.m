//
//  dmkMyScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 3/25/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "dmkMyScene.h"
#define ARC4RANDOM_MAX  0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}


@implementation dmkMyScene
{
}
@synthesize motionManager;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Level1"];
        bg.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        bg.size = CGSizeMake(self.size.width, self.size.height);
        bg.anchorPoint = CGPointMake(0.5, 0.5);
        [self addChild:bg];
        
        self.motionManager = [[CMMotionManager alloc] init];
        [self.motionManager startAccelerometerUpdates];
        
        for (int i = 1; i < 5; i++) {
            [self spawnCowAtLocation:5 leftBound:40 rightBound:300];
        }
        
        
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.5, 40.0, self.size.width, self.size.height - 40)];
    }
    return self;
}

- (void)spawnCowAtLocation:(int)count
                 leftBound:(CGFloat)lBound
                rightBound:(CGFloat)rBound
{
    // Set random spawn point
    CGFloat spawnPointX = ScalarRandomRange(lBound, rBound);
    CGFloat spawnPointY = ScalarRandomRange(50, 100);
    
    // Create Cow
    SKSpriteNode *cow = [SKSpriteNode spriteNodeWithImageNamed:@"Cow2"];
    cow.position = CGPointMake(spawnPointX, spawnPointY);
    NSLog(@"Cow Position: x: %f, y: %f", spawnPointX, spawnPointY);
    
   
    
    // Assign name
    cow.name = @"cow";
    
    
    // Create physics object around the cow
    CGSize contactSize = CGSizeMake(cow.size.width / 2, cow.size.height / 2);
    cow.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
 
    // Add cow to screen
    [self addChild:cow];
    
    
    SKAction *grow = [SKAction scaleTo:1.5 duration:1.0];
    SKAction *undoGrow = [SKAction scaleTo:1.0 duration:1.0];
    [cow runAction:[SKAction repeatActionForever:
                    [SKAction sequence:@[grow, undoGrow]]]];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    for (SKSpriteNode *node in self.children) {
        if ([node.name isEqualToString:@"cow"]) {
            if (touchLocation.x < node.position.x) {
                [node.physicsBody applyImpulse:CGVectorMake(arc4random() % 8, arc4random() % 5)];
                //NSLog(@"%u",arc4random() % 8);
            }
            if (touchLocation.x > node.position.x) {
                [node.physicsBody applyImpulse:CGVectorMake(-2, 5)];
                //NSLog(@"%i", (int)(arc4random() % 8) * -1);
            }
        }
    }

}


/**
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}
*/

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
}

@end
