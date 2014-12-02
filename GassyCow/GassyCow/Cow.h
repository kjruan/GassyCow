//
//  cow.h
//  GassyCow
//
//  Created by Kevin Ruan on 8/8/14.
//  Copyright (c) 2014 Kevin Ruan. All rights reserved.
//

#import "Entity.h"

@interface Cow : Entity

-(SKNode *)initWithPosition:(CGPoint)position
                     facing:(CGFloat)facing;
-(SKAction *)walk;
-(void)fly;

@end
