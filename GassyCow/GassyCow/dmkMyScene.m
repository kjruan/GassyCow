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
#import "SKTUtils.h"

#define ARC4RANDOM_MAX  0x100000000

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryCow = 1 << 0,      // 0001 = 1
    CNPhysicsCategoryBlock = 1 << 1,    // 0010 = 2
    CNPhysicsCategoryEdge = 1 << 3,     // 1000 = 8
    CNPhysicsCategoryLabel = 1 << 4,    // 10000 = 16
    CNPhysicsCategoryBase = 1 << 5,     // 100000 = 32
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
    SKNode *_bgLayer;
    SKNode *_gameNode;
    SKNode *_hudLayer;
    SKNode *_cowLayer;
    SKNode *_penLayer;
    SKNode *_penCowLayer;
    SKLabelNode *_scoreLabel;
    
    SKAction *_cowAnimation;
    int _currentLevel;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    int _cowNumber;
    int _score;
}
@synthesize motionManager;


- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _bgLayer = [SKNode node];
        [self addChild:_bgLayer];
        
        _gameNode = [SKNode node]; // Push all other objects to _gameNode.
        [self addChild:_gameNode];
        
        _hudLayer = [SKNode node]; // Push all hud objects to _hudLayer.
        [self addChild:_hudLayer];
        
        _penLayer = [SKNode node]; // Add pen layer to hold returned cows.
        [_gameNode addChild:_penLayer];
        
        _cowLayer = [SKNode node];
        [_gameNode addChild:_cowLayer];
        
        /* Setup your scene here */
        [self initializeWithScene];
        
        // Setup level
        _currentLevel = 1;
        [self SetupLevel:_currentLevel];
    }
    return self;
}

- (void)initializeWithScene
{

    // Setup main screen attributes
    //CGRect customRect = CGRectMake(0, 50, self.frame.size.width, self.frame.size.height - 50);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 50) toPoint:CGPointMake(self.frame.size.width, 50)]; // bodyWithEdgeLoopFromRect:customRect];
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0, -9.8);
    self.physicsBody.collisionBitMask = CNPhysicsCategoryEdge;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryLabel | CNPhysicsCategoryBase;
    self.name = @"self";
    
    //Setup background
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Level_1"];
    bg.position = CGPointMake(self.size.width , self.size.height );
    bg.size = CGSizeMake(self.size.width * 2, self.size.height * 2);
    bg.anchorPoint = CGPointMake(0.5, 0.6);
    [_bgLayer addChild:bg];
    
    //Debug
    //NSLog(@"x: %f, y: %f, parent %@", pen.position.x, pen.position.y, [pen parent]);
}

- (void)spawnCowAtLocation:(CGPoint)pos
                          :(int)count
{
    NSMutableArray *cows = [[NSMutableArray alloc] initWithCapacity:50]; // Reserve 50 cow objects in array
    for (int i = 0; i < count; i++ )
    {
        CGPoint modpos = CGPointMake(pos.x + ScalarRandomRange(0.0, 80.0), pos.y + ScalarRandomRange(0.0, 1.0));

        Cow *_cow = [[Cow alloc] initWithPosition:modpos];
  
        _cow.physicsBody.categoryBitMask = CNPhysicsCategoryCow;
        _cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge | CNPhysicsCategoryBase;
        _cow.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryBase;
        
        // Add debug square
        //[_cow attachDebugRectWithSize:_cow.size];
        
        NSLog(@"x: %f, y: %f", modpos.x, modpos.y);
        
        [cows addObject:_cow];
    }
    
    for (int i = 0; i < cows.count; i++)
    {
        [_cowLayer addChild:[cows objectAtIndex:i]];
        [[cows objectAtIndex:i] runAction:[[cows objectAtIndex:i] walk] completion:^
            {
                [[cows objectAtIndex:i] fly];
            }
        ];
    }
}

- (void)spawnPenAtLocation:(CGPoint)pos
{
    _penCowLayer = [SKNode node];
    [_penLayer addChild:_penCowLayer];
    
    SKSpriteNode *pen = [SKSpriteNode spriteNodeWithImageNamed:@"Base"];
    pen.name = @"pen";
    pen.position = pos;
    pen.size = CGSizeMake(pen.size.width/2, pen.size.height/2);
    pen.anchorPoint = CGPointMake(0.5, 0.5);
    
    pen.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pen.size];
    pen.physicsBody.categoryBitMask = CNPhysicsCategoryBase;
    pen.physicsBody.collisionBitMask = CNPhysicsCategoryCow;
    pen.physicsBody.contactTestBitMask = CNPhysicsCategoryCow;
    [_penLayer addChild:pen];

}

- (void)SetupLevel:(int)levelNum
{
    // Add Background audio
    
    // Load the plist file
    NSString *fileName = [NSString stringWithFormat:@"level%i", levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    _cowNumber = (int)[[level objectForKey:@"cowCount"] integerValue];
    
    // Reset Score
    //Setup basic hud
    _score = 0;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    _scoreLabel.text = @"Score: 0";
    _scoreLabel.fontSize = 20.0;
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreLabel.position = CGPointMake(10, self.scene.size.height - 40);
    [_hudLayer addChild:_scoreLabel];
    
    [self spawnCowAtLocation:CGPointFromString(level[@"cowPosition"]):(int)[[level objectForKey:@"cowCount"] integerValue]];
    [self spawnPenAtLocation:CGPointFromString(level[@"penPosition"])];
    
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
             
             cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge | CNPhysicsCategoryBase;
             //CGPoint cowPos = body.node.position;
             CGFloat cowRotation = body.node.zRotation;

             //NSLog(@"x: %f, y: %f, z: %f", cowPos.x, cowPos.y, cowRotation);
             //[body applyImpulse:CGVectorMake(0, 0.5) atPoint:CGPointMake(cow.size.width/2, cow.size.height/2)];
             [cow removeActionForKey:@"walking"];
             //body.affectedByGravity = false;
             cow.physicsBody.allowsRotation = NO;
             cow.physicsBody.angularDamping = 0.0001;
             [body applyForce:[self travelVector:cowRotation] atPoint:CGPointMake(0.0, 0.0)];
             
             
             if (_cowNumber == 0) {
                 [self win];
             }
         }
    }];
}

-(void)setCowInPen
{
    SKSpriteNode *cow = [SKSpriteNode spriteNodeWithImageNamed:@"Cow1"];
    CGFloat cowPostionX = ScalarRandomRange(1, 20);
    //NSLog(@"%f",[_penLayer childNodeWithName:@"pen"].position.x);
    
    cow.position = CGPointMake([_penLayer childNodeWithName:@"pen"].position.x + cowPostionX, [_penLayer childNodeWithName:@"pen"].position.y);
    [_penCowLayer addChild:cow];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (CNPhysicsCategoryCow|CNPhysicsCategoryBase)) {
        if (contact.bodyA.categoryBitMask == CNPhysicsCategoryCow)
        {
            [contact.bodyA.node removeFromParent];
        } else {
            [contact.bodyB.node removeFromParent];
        }
        [self setCowInPen];
        _score += 1;
        _cowNumber -= 1;
    }
    
    if (_cowNumber == 0) {
        [self win];
    }
}


// Test travel vector... needs to implement in the cow class, testing here. 
-(CGVector)travelVector:(CGFloat)zRotation
{
    // Depending on direction of the launch... 180 spin = PI, additional spin > 180 = NEG PI.
    // When cow launches facing left, PI < 0 as the cow spins clockwise.
    CGVector v = CGVectorMake(0, 0);
    if (zRotation > 0 && zRotation < M_PI / 2)
        v = CGVectorMake(-10, -10);
    else if (zRotation > M_PI / 2 && zRotation < M_PI)
        v = CGVectorMake(10, -10);
    else if (zRotation > -M_PI && zRotation < -M_PI / 2)
        v = CGVectorMake(10, 10);
    else
        v = CGVectorMake(-10, 10);
    //NSLog(@"Vector dx: %f, dy: %f", v.dx, v.dy);
    //NSLog(@"M_PI value: %f", M_PI);
    
    return v;
}



-(void)win {
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:5.0],
                                         [SKAction performSelector:@selector(newGame) onTarget:self]]]];
}

-(void)newGame {
    [_hudLayer removeAllChildren];
    [_cowLayer removeAllChildren];
    [_penLayer removeAllChildren];
    [self SetupLevel:1];
}


-(void)update:(CFTimeInterval)currentTime {
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %d, Cows: %d", _score, _cowNumber];
 
    //NSLog(@"%f, %f", [_cowLayer.children[0] position].x, [_cowLayer.children[0] position].y);
    
}

@end
