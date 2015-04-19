//
//  dmkOptionsScene.m
//  GassyCow
//
//  Created by Kevin Ruan on 4/11/15.
//  Copyright (c) 2015 Kevin Ruan. All rights reserved.
//

#import "dmkOptionsScene.h"
#import "dmkMyScene.h"

@implementation dmkOptionsScene
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
        
        _btnLayer = [SKNode node];
        [self addChild:_btnLayer];
        
        SKLabelNode *options = [self showOptions:@"Menlo-Regular" color:[UIColor whiteColor] size:16.0 string:@"Reset Score and cow"];
        options.position = CGPointMake(self.size.width/2, self.size.height/2);
        [_btnLayer addChild:options];
        
        SKLabelNode *backBtn = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Regular"];
        backBtn.name = @"backBtn";
        backBtn.fontColor = [UIColor whiteColor];
        backBtn.fontSize = 12.0;
        backBtn.position = CGPointMake(self.size.width/2, self.size.height/8);
        backBtn.text = @"Back";
        [_btnLayer addChild:backBtn];
    }
    return self;
}

- (SKLabelNode *)showOptions:(NSString *)font
                       color:(UIColor *)color
                        size:(CGFloat)size
                      string:(NSString *)text
{
    SKLabelNode *credits = [SKLabelNode labelNodeWithFontNamed:font];
    credits.fontColor = color;
    credits.fontSize = size;
    credits.text = @"Programmming: Keviar Graphics: Chainsaw";
    return credits;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"backBtn"]) {
        
        dmkMyScene * myScene =
        [[dmkMyScene alloc] initWithSize:self.size];
        
        SKTransition *reveal =
        [SKTransition doorwayWithDuration:0.5];
        
        [self.view presentScene:myScene transition: reveal];
    }
}

@end
