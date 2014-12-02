//
//  dmkCreditScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 11/28/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "dmkCreditScene.h"
#import "dmkMainMenuScene.h"

@implementation dmkCreditScene
{
    SKNode *_txtLayer;
    SKNode *_btnLayer;
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:size];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bg];
        
        _txtLayer = [SKNode node];
        [self addChild:_txtLayer];
        
        _btnLayer = [SKNode node];
        [self addChild:_btnLayer];
        
        SKLabelNode *credits = [self showCredits:@"Menlo-Regular" color:[UIColor whiteColor] size:16.0];
        credits.position = CGPointMake(self.size.width/2, self.size.height/2);
        [_txtLayer addChild:credits];
        
        SKLabelNode *backBtn = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
        backBtn.name = @"backBtn";
        backBtn.fontColor = [UIColor whiteColor];
        backBtn.fontSize = 12.0;
        backBtn.position = CGPointMake(self.size.width/2, self.size.height/8);
        backBtn.text = @"Main Menu";
        [_btnLayer addChild:backBtn];
    }
    return self;
}

- (SKLabelNode *)showCredits:(NSString *)font
                       color:(UIColor *)color
                        size:(CGFloat)size
{
    SKLabelNode *credits = [SKLabelNode labelNodeWithFontNamed:font];
    credits.fontColor = color;
    credits.fontSize = size;
    credits.text = @"Programmming: Kevin Ruan Graphics: David Geib";
    return credits;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"backBtn"]) {
        
        dmkMainMenuScene * myScene =
        [[dmkMainMenuScene alloc] initWithSize:self.size];
        
        SKTransition *reveal =
        [SKTransition doorwayWithDuration:0.5];
        
        [self.view presentScene:myScene transition: reveal];
    }
}

@end
