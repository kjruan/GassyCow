//
//  dmkMainMenuScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 11/23/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "dmkMainMenuScene.h"
#import "dmkMyScene.h"
#import "dmkCreditScene.h"

@implementation dmkMainMenuScene
{
    SKNode *_btnLayer;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:size];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bg];
        
        _btnLayer = [SKNode node];
        [self addChild:_btnLayer];
        
        SKLabelNode *startBtn = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
        startBtn.name = @"startBtn";
        startBtn.fontColor = [UIColor whiteColor];
        startBtn.position = CGPointMake(self.size.width/2, self.size.height/2 + 50);
        startBtn.text = @"Start";
        
        SKLabelNode *creditBtn = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
        creditBtn.name = @"creditBtn";
        creditBtn.fontColor = [UIColor whiteColor];
        creditBtn.position = CGPointMake(self.size.width/2, self.size.height/4);
        creditBtn.text = @"Credits";
        
        [_btnLayer addChild:startBtn];
        [_btnLayer addChild:creditBtn];

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"startBtn"]) {
    
        dmkMyScene * myScene =
        [[dmkMyScene alloc] initWithSize:self.size];
    
        SKTransition *reveal =
        [SKTransition doorwayWithDuration:0.5];
    
    
        [self.view presentScene:myScene transition: reveal];
    }
    
    if ([node.name isEqualToString:@"creditBtn"]) {
        dmkCreditScene *myScene =
        [[dmkCreditScene alloc] initWithSize:self.size];
        
        SKTransition *reveal =
        [SKTransition doorwayWithDuration:0.5];
        
        
        [self.view presentScene:myScene transition: reveal];
    }
}




@end
