//
//  dmkMyScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 3/25/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "dmkMyScene.h"
#import "DebugDraw.h"
#import "Cow.h"

#define ARC4RANDOM_MAX  0x100000000

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryCow = 1 << 0,      // 0001 = 1
    CNPhysicsCategoryBlock = 1 << 1,    // 0010 = 2
    CNPhysicsCategoryEdge = 1 << 3,     // 1000 = 8
    CNPhysicsCategoryLabel = 1 << 4,    // 10000 = 16
};

static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

@interface dmkMyScene()<SKPhysicsContactDelegate>
@end

@implementation dmkMyScene
{
    SKNode *_gameNode;
    SKAction *_cowAnimation;
    int _currentLevel;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
}
@synthesize motionManager;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self initializeWithScene];
        
        _gameNode = [SKNode node]; // Push all other objects to _gameNode.
        [self addChild:_gameNode];
        
        // Setup level
        _currentLevel = 1;
        [self SetupLevel:_currentLevel];
    }
    return self;
}

- (void)initializeWithScene
{
    CGRect customRect = CGRectMake(0, 50, self.frame.size.width, self.frame.size.height - 50);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:customRect];
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0, -9.8);
    
    self.physicsBody.collisionBitMask = CNPhysicsCategoryEdge;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryLabel;
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Level1"];
    bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    bg.size = CGSizeMake(self.size.width, self.size.height);
    bg.anchorPoint = CGPointMake(0.5, 0.5);
    [self addChild:bg];
}

- (void)spawnCowAtLocation:(CGPoint)pos
{
    Cow *_cow = [[Cow alloc] initWithPosition:pos];
    _cow.texture = [Cow generateTexture];

    _cow.name = @"cow";
    _cow.position = pos;
    
    [_gameNode addChild:_cow];
    
    CGSize contactSize = CGSizeMake(_cow.size.width/2, _cow.size.height/2);
    
    _cow.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
    _cow.physicsBody.categoryBitMask = CNPhysicsCategoryCow;
    _cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge;
    _cow.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge; //| CNPhysicsCategoryCowPen
    
    // Add debug square
    [_cow attachDebugRectWithSize:_cow.size];
    
    // Walk and lift off!! Still super spinny...
    [_cow runAction:[_cow walk] completion:^{
        [_cow removeActionForKey:@"walkingAnimation"];
        [_cow fly];
    }];
}


- (void)SetupLevel:(int)levelNum
{
    // Add Background audio
    
    // Load the plist file
    NSString *fileName = [NSString stringWithFormat:@"level%i", levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self spawnCowAtLocation:CGPointFromString(level[@"cowPosition"])];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // removes walking animation when cow is touched
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:
     ^(SKPhysicsBody *body, BOOL *stop) {
         if (body.categoryBitMask == CNPhysicsCategoryCow) {
             SKSpriteNode *cow = (SKSpriteNode *)body.node;
             cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge;
             CGPoint cowPos = body.node.position;
             CGFloat cowRotation = body.node.zRotation;

             NSLog(@"x: %f, y: %f, z: %f", cowPos.x, cowPos.y, cowRotation);
             //[body applyImpulse:CGVectorMake(0, 0.5) atPoint:CGPointMake(cow.size.width/2, cow.size.height/2)];
             [cow removeActionForKey:@"walking"];
             //body.affectedByGravity = false;
             cow.physicsBody.allowsRotation = NO;
             [body applyForce:[self travelVector:cowRotation] atPoint:CGPointMake(0.0, 0.0)];
             [self travelVector:cowRotation];
         }
    }];
}

// Test travel vector... needs to implement in the cow class, testing here. 
-(CGVector)travelVector:(CGFloat)zRotation
{
    // Depending on direction of the launch... 180 spin = PI, additional spin > 180 = NEG PI.
    // When cow launches facing left, PI < 0 as the cow spins clockwise.
    CGVector v = CGVectorMake(0, 0);
    if (zRotation < 0 && zRotation > M_PI / 2 * -1) {
        v = CGVectorMake(-10, -10);
    } else
        v = CGVectorMake(10, 10);
    NSLog(@"Vector dx: %f, dy: %f", v.dx, v.dy);
    NSLog(@"M_PI value: %f", M_PI);
    
    return v;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    */
    //NSLog(@"%@", [_gameNode children]);
    
}

@end
