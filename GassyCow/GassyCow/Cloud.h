//
//  Cloud.h
//  GassyCow
//
//  Created by Kevin Ruan on 4/27/15.
//  Copyright (c) 2015 Kevin Ruan. All rights reserved.
//

#import "Entity.h"

@interface Cloud : Entity

-(SKNode *)initWithPosition:(CGPoint)position;
-(CGVector)travelVector:(CGFloat)zRotation;

@end
