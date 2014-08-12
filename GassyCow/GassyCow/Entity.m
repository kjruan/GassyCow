//
//  Entity.m
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "Entity.h"

@implementation Entity

-(instancetype)initWithPosition:(CGPoint)position
{
    if (self = [super init]) {
        self.texture = [[self class] generateTexture];
        self.size = self.texture.size;
        self.position = position;
        _direction = CGPointZero;
    }
    return self;
}

-(void)update:(CFTimeInterval)delta
{
    // Overridden by subclasses
}

+(SKTexture *)generateTexture
{
    // Overridden by subclasses
    return nil;
}

@end
