//
//  dmkMyScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 3/25/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "dmkMyScene.h"
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
    SKSpriteNode *cow = [SKSpriteNode spriteNodeWithImageNamed:@"Cow2"];
    cow.name = @"cow";
    cow.position = pos;
    
    [_gameNode addChild:cow];
    
    CGSize contactSize = CGSizeMake(cow.size.width/2, cow.size.height/2);
    
    cow.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
    cow.physicsBody.categoryBitMask = CNPhysicsCategoryCow;
    cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge;
    cow.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge; //| CNPhysicsCategoryCowPen
    

}


- (void)cowWonder:(SKNode *)cow {
    SKAction *wait = [SKAction waitForDuration:5];
    SKAction *wonderLeft = [SKAction sequence:@[[SKAction scaleXTo:cow.xScale * -1 duration:0],[SKAction moveByX:15 y:0 duration:5]]];
    SKAction *wonderRight = [SKAction sequence:@[[SKAction scaleXTo:cow.xScale duration:0],[SKAction moveByX:-15 y:0 duration:5]]];
    [cow runAction:[SKAction repeatActionForever:[SKAction sequence:@[wonderLeft, wait, wonderRight]]] withKey:@"cowWonder"];
    
}

- (void)cowFloat:(SKNode *)cow {
    cow.physicsBody.affectedByGravity = NO;
    [[cow physicsBody] applyForce:CGVectorMake(0.5, 0.01) atPoint:CGPointMake(0.0, 0.0)];
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
    //cow.physicsBody.mass
    cow.physicsBody.allowsRotation = NO;
    cow.physicsBody.angularDamping = 1;
    
    // Add cow to screen
    [self addChild:cow];
    
    
    SKAction *grow = [SKAction scaleTo:1.5 duration:1.0];
    SKAction *undoGrow = [SKAction scaleTo:1.0 duration:1.0];
    [cow runAction:[SKAction repeatActionForever:
                    [SKAction sequence:@[grow, undoGrow]]]];
    
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
    
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:
     ^(SKPhysicsBody *body, BOOL *stop) {
         if (body.categoryBitMask == CNPhysicsCategoryCow) {
             SKSpriteNode *cow = (SKSpriteNode *)body.node;
             cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge;
             [body applyImpulse:CGVectorMake(0, 0.5) atPoint:CGPointMake(cow.size.width/2, cow.size.height/2)];
             [cow removeActionForKey:@"cowWonder"];
         }
     }];
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    NSInteger ti = (NSInteger)currentTime;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    NSLog(@"%02ld", _dt);
    
    
    
}

@end
