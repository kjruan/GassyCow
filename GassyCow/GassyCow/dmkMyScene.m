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
#import "Cloud.h"
#import "SKTUtils.h"
@import AVFoundation;


#define ARC4RANDOM_MAX  0x100000000

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryCow = 1 << 0,      // 0001 = 1
    CNPhysicsCategoryBlock = 1 << 1,    // 0010 = 2
    CNPhysicsCategoryEdge = 1 << 3,     // 1000 = 8
    CNPhysicsCategoryLabel = 1 << 4,    // 10000 = 16
    CNPhysicsCategoryBase = 1 << 5,     // 100000 = 32
    CNPhysicsCategoryBounds = 1 << 6,    // 1000000 = 64
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
    SKNode *_boundLayer;
    SKNode *_bgLayer;
    SKNode *_gameNode;
    SKNode *_hudLayer;
    SKNode *_cloudLayer;
    SKNode *_cowLayer;
    SKNode *_penLayer;
    SKNode *_penCowLayer;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_resetLabel;
    
    SKAction *_cowAnimation;

    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    int _currentLevel;
    int _cowNumber;
    int _score;
    int _lostCowCount;
    
    NSString *_path;
    NSString *_path_score;
    
    AVAudioPlayer *_backgroundMusicPlayer;
}
@synthesize motionManager;


- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _boundLayer = [SKNode node];
        [self addChild:_boundLayer];
        
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
        
        _cloudLayer = [SKNode node];
        [_gameNode addChild:_cloudLayer];
        
        // Read settings
        [self copyPlistFromBundleToFile];
        
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
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 15) toPoint:CGPointMake(self.frame.size.width, 15)]; // bodyWithEdgeLoopFromRect:customRect];
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0, -9.8);
    self.physicsBody.collisionBitMask = CNPhysicsCategoryEdge;
    self.physicsBody.contactTestBitMask = CNPhysicsCategoryBase;
    self.name = @"self";
    
    // Setup boundaries
    CGRect customRect = CGRectMake(-50, 0, self.size.width + 100, self.size.height + 50);
    SKNode *bounds = [SKNode node];
    SKPhysicsBody *boundsPhysics = [SKPhysicsBody bodyWithEdgeLoopFromRect:customRect];
    boundsPhysics.categoryBitMask = CNPhysicsCategoryBounds;
    boundsPhysics.contactTestBitMask = CNPhysicsCategoryCow;
    bounds.physicsBody = boundsPhysics;
    [_boundLayer addChild:bounds];
    
    [self playBackgroundMusic:@"Theme1.mp3"];
    
}

- (void)copyPlistFromBundleToFile
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    _path = [documentsDirectory stringByAppendingPathComponent:@"level1.plist"]; //3
    _path_score =[documentsDirectory stringByAppendingPathComponent:@"highscore.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: _path]) //4
    {
        NSString *bundle_1 = [[NSBundle mainBundle] pathForResource:@"level1" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle_1 toPath: _path error:&error]; //6
    }
    
    if (![fileManager fileExistsAtPath: _path_score]) //4
    {
        NSString *bundle_2 = [[NSBundle mainBundle] pathForResource:@"highscore" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle_2 toPath: _path_score error:&error]; //6
    }
    
}


- (void)setBackgroundImage:(NSString *)bgName
{
    //Setup background
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:bgName];
    bg.position = CGPointMake(self.size.width / 2 , self.size.height / 2 );
    bg.size = CGSizeMake(self.size.width, self.size.height);
    bg.anchorPoint = CGPointMake(0.5, 0.5);
    [_bgLayer addChild:bg];
}

- (void)spawnCloudAtLocation:(CGPoint)cloudPosX
                            :(CGPoint)cloudPosY
                            :(CGPoint)cloudCnt
{
    CGFloat count = ScalarRandomRange(cloudCnt.x, cloudCnt.y);
    
    for (int i = 0; i < count; i++) {
        CGFloat randPosX = ScalarRandomRange(cloudPosX.x, cloudPosX.y);
        CGFloat randPosY = ScalarRandomRange(cloudPosY.x, cloudPosY.y);
        CGPoint pos = CGPointMake(randPosX, randPosY);
        Cloud *_cloud = [[Cloud alloc] initWithPosition:pos];
        [_cloudLayer addChild:_cloud];
        [_cloud runAction:[_cloud moveCloud]];
        
    }
}


- (void)spawnCowAtLocation:(CGPoint)pos
                          :(int)count
{
    NSMutableArray *cows = [[NSMutableArray alloc] initWithCapacity:0]; // New array every level. 
    for (int i = 0; i < count; i++ )
    {
        CGPoint modpos = CGPointMake(pos.x + ScalarRandomRange(10.0, 200.0), pos.y + ScalarRandomRange(0.0, 1.0));
        
        Cow *_cow = [[Cow alloc] initWithPosition:modpos];
        
        _cow.physicsBody.categoryBitMask = CNPhysicsCategoryCow;
        _cow.physicsBody.collisionBitMask = CNPhysicsCategoryCow | CNPhysicsCategoryEdge | CNPhysicsCategoryBase;
        _cow.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryBase;
        
        // Add debug square
        //[_cow attachDebugRectWithSize:_cow.size];
        //NSLog(@"x: %f, y: %f", modpos.x, modpos.y);
        
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

- (void)spawnPenAtLocation:(NSString *)penImgName
                       pos:(CGPoint)pos
{
    _penCowLayer = [SKNode node];
    [_penLayer addChild:_penCowLayer];
    
    SKSpriteNode *pen = [SKSpriteNode spriteNodeWithImageNamed:penImgName];
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
    // Load the plist file
    NSString *fileName = [NSString stringWithFormat:@"level%i", levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    _cowNumber = [self getCowNumber];
    _lostCowCount = 0;
    
    // Reset Score
    _resetLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    _resetLabel.name = @"Reset";
    _resetLabel.text = @"Reset";
    _resetLabel.fontSize = 20.0;
    _resetLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _resetLabel.position = CGPointMake(self.scene.size.width - 80, self.scene.size.height - 40);
    [_hudLayer addChild:_resetLabel];
    
    //Setup basic hud
    _score = [self getPlayerHighScore];
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
    _scoreLabel.text = @"Score: 0";
    _scoreLabel.fontSize = 20.0;
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreLabel.position = CGPointMake(10, self.scene.size.height - 40);
    [_hudLayer addChild:_scoreLabel];
    
    [self setBackgroundImage:[level objectForKey:@"bgImgName"]];
    [self spawnCowAtLocation:CGPointFromString(level[@"cowPosition"]):[self getCowNumber]];
    [self spawnPenAtLocation:[level objectForKey:@"penImgName"] pos: CGPointFromString(level[@"penPosition"])];
    [self spawnCloudAtLocation:CGPointFromString(level[@"cloudPosX"]) :CGPointFromString(level[@"cloudPosY"]) :CGPointFromString(level[@"cloudCountRange"])];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *reset = [self nodeAtPoint:location];
    if ([reset.name isEqualToString:@"Reset"])
    {
        [self resetGame];
    }
    
    // removes walking animation when cow is touched
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:
     ^(SKPhysicsBody *body, BOOL *stop) {
         if (body.categoryBitMask == CNPhysicsCategoryCow) {
             Cow *cow = (Cow *)body.node;
             
             CGFloat cowRotation = body.node.zRotation;
             CGFloat fartSoundRand = ScalarRandomRange(1, 21);
             int fart = (int) roundf(fartSoundRand);

             [self runAction:[SKAction playSoundFileNamed:[NSString stringWithFormat:@"Fart%i.mp3", fart] waitForCompletion:NO]];

             //NSString *test = [NSString stringWithFormat:@"Fart%i", integerWidth];
             //NSLog(@"Touch with fart sound: %@", test);
             [cow startFartEmitter:cowRotation];
             [body applyForce:[cow travelVector:cowRotation]]; // atPoint:CGPointMake(cow.size.width/2, cow.size.height/2)];
         }
    }];
}

- (void)setCowInPen
{
    CGFloat mooSoundRand = ScalarRandomRange(1, 14);
    int moo = (int) roundf(mooSoundRand);
    [self runAction:[SKAction playSoundFileNamed:[NSString stringWithFormat:@"Moo%i.mp3", moo] waitForCompletion:NO]];
    //NSLog(@"%f",[_penLayer childNodeWithName:@"pen"].position.x);
    
    CGPoint modpos = CGPointMake([_penLayer childNodeWithName:@"pen"].position.x + ScalarRandomRange(1.0, 30.0), [_penLayer childNodeWithName:@"pen"].position.y);
    
    Cow *_cow = [[Cow alloc] initWithPosition:modpos];
    _cow.physicsBody = nil;
    
    [_penCowLayer addChild:_cow];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
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
        [self setPlayerHighScore:[self getPlayerHighScore] + 1];
        _cowNumber -= 1;
    }
    
    if (collision == (CNPhysicsCategoryCow|CNPhysicsCategoryBounds)) {
        if (contact.bodyA.categoryBitMask == CNPhysicsCategoryCow)
        {
            [contact.bodyA.node removeFromParent];
        } else {
            [contact.bodyB.node removeFromParent];
        }
        _cowNumber -= 1;
        _lostCowCount += 1;
    }
    
    if (_cowNumber == 0) {
        [self win];
    }
}

- (void)win {
    if (_lostCowCount == 0)
        [self setCowNumber:[self getCowNumber] + 1];
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:5.0],
                                         [SKAction performSelector:@selector(newGame) onTarget:self]]]];
}

- (void)newGame {
    [_hudLayer removeAllChildren];
    [_cowLayer removeAllChildren];
    [_penLayer removeAllChildren];
    [_cloudLayer removeAllChildren];

    [self SetupLevel:1]; // Only one level. Increases cow by one every game.
}


- (void)playBackgroundMusic:(NSString *)filename
{
    NSError *error;
    
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _backgroundMusicPlayer.numberOfLoops = -1;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
}

- (void)setPlayerHighScore:(int)score
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: _path_score];
    int value = score;
    [data setObject:[NSNumber numberWithInt:value] forKey:@"score"];
    [data writeToFile: _path_score atomically:YES];
}

- (int)getPlayerHighScore
{
    NSMutableDictionary *level = [[NSMutableDictionary alloc] initWithContentsOfFile: _path_score];
    int value;
    value = [[level objectForKey:@"score"] intValue];
    return value;
}


- (void)setCowNumber:(int)count
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: _path];
    int value = count;
    [data setObject:[NSNumber numberWithInt:value] forKey:@"cowCount"];
    [data writeToFile: _path atomically:YES];

}

- (int)getCowNumber
{
    NSMutableDictionary *level = [[NSMutableDictionary alloc] initWithContentsOfFile: _path];
    int value;
    value = [[level objectForKey:@"cowCount"] intValue];
    return value;
}

- (void)resetGame
{
    [self setPlayerHighScore:0];
    [self setCowNumber:1];
    [self runAction:[SKAction performSelector:@selector(newGame) onTarget:self]];
}

- (void)update:(CFTimeInterval)currentTime {
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }

    _lastUpdateTime = currentTime;
    _scoreLabel.text = [NSString stringWithFormat:@"Hi-Score: %d, Cows: %d", _score, _cowNumber];

}

@end
