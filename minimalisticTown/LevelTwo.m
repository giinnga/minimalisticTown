//
//  LevelTwo.m
//  minimalisticTown
//
//  Created by Victor Souza on 2/24/15.
//  Copyright (c) 2015 Victor Souza. All rights reserved.
//

#import "LevelTwo.h"

@implementation LevelTwo
{
    SKSpriteNode *_escada;
    SKSpriteNode *_ambulancia;
    SKSpriteNode *_balao;
    
    BOOL _hideIt;
}

-(void)didMoveToView:(SKView *)view {
    
//    Flags
    
    _hideIt = YES;
    
//    Background
    
    SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"Fundo-Level2@3x.png"];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
    background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
    background.zPosition = 1;
    [self addChild:background];
    
//    Hospital
    
    SKSpriteNode *hospital = [SKSpriteNode spriteNodeWithImageNamed:@"Hospital-Level2"];
    hospital.position = CGPointMake(self.size.width - hospital.size.width/1.8, self.size.height/1.8);
    hospital.zPosition = 2;
    [self addChild:hospital];
    
    
//    Escada
    
    _escada = [SKSpriteNode spriteNodeWithImageNamed:@"Escada-Level2"];
    _escada.zPosition = 3;
    _escada.position = CGPointMake(hospital.position.x + 4.9 * _escada.size.width,
                                   hospital.position.y - _escada.size.height/1.7);
    _escada.name = @"escada";
    [self addChild:_escada];
    
//    Carro
    
    _ambulancia = [SKSpriteNode spriteNodeWithImageNamed:@"Ambulancia-Level2"];
    _ambulancia.position = CGPointMake(self.size.width/2 - _ambulancia.size.width/2,
                                       self.size.height/3);
    _ambulancia.zPosition = 3;
    [self addChild:_ambulancia];
    
//    Balao
    
    _balao = [SKSpriteNode spriteNodeWithImageNamed:@"Balao-Level2"];
    _balao.position = CGPointMake(_ambulancia.position.x + _balao.size.width/2,
                                  _ambulancia.position.y - _balao.size.height/3);
    _balao.zPosition = 2;
    _balao.anchorPoint = CGPointMake(0, 1);
    _balao.hidden = YES;
    [self addChild:_balao];
    
    SKAction *hide = [SKAction performSelector:@selector(hide) onTarget:self];
    SKAction *waitWhileShown = [SKAction waitForDuration:1];
    SKAction *waitWhileHidden = [SKAction waitForDuration:1];
    [_balao runAction:[SKAction repeatActionForever:
                       [SKAction sequence:@[waitWhileHidden,hide,waitWhileShown,hide]]] withKey:@"hideAction"];
    
}

-(void)hide {
    if (_hideIt) {
        _balao.hidden = !_balao.hidden;
    }
}

@end
