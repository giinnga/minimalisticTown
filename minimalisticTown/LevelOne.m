//
//  GameScene.m
//  minimalisticTown
//
//  Created by Victor Souza on 2/24/15.
//  Copyright (c) 2015 Victor Souza. All rights reserved.
//

@import CoreMotion;

#import "LevelOne.h"
#import "LevelTwo.h"

@implementation LevelOne
{
    BOOL _cloud;
    BOOL _hideIt;
    BOOL _houseMove;
    
    SKSpriteNode *_cloudNode;
    SKSpriteNode *_balao;
    SKSpriteNode *_casa;
    
    SKEmitterNode *_explosionEmitter;
    
    SKTexture *_backgroundTexture;
    
    CMMotionManager *_motionManager;
}

static inline CGPoint CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

static inline CGPoint CGPointSubtract(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

static inline GLKVector2 GLKVector2FromCGPoint(CGPoint point) {
    return GLKVector2Make(point.x, point.y);
}

static inline CGPoint CGPointFromGLKVector2(GLKVector2 vector) {
    return CGPointMake(vector.x, vector.y);
}

static inline CGPoint CGPointMultiplyScalar(CGPoint point, CGFloat value) {
    return CGPointFromGLKVector2(GLKVector2MultiplyScalar(GLKVector2FromCGPoint(point), value));
}

-(void)didMoveToView:(SKView *)view {
  
//    Setup your scene here
    
    _cloud = NO;
    _hideIt = YES;
    _houseMove = YES;
    
//    Background
    
    _backgroundTexture = [SKTexture textureWithImageNamed:@"Fundo-Level1@3x.png"];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:_backgroundTexture size:self.view.frame.size];
    background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
    background.zPosition = 1;
    [self addChild:background];
    
//    Casa
    
    _casa = [SKSpriteNode spriteNodeWithImageNamed:@"Casa-Level1"];
    _casa.position = CGPointMake(self.size.width/3.5, self.size.height/2.5);
    _casa.zPosition = 2;
    [self addChild:_casa];
    
//    Cloud
    
    _cloudNode = [SKSpriteNode spriteNodeWithImageNamed:@"Nuvem-Level1"];
    _cloudNode.position = CGPointMake(_casa.position.x, self.size.height - _cloudNode.size.height);
    _cloudNode.zPosition = 3;
    _cloudNode.name = @"cloud";
    [self addChild:_cloudNode];
    
    [self rain];
    
//    Balão
    
    _balao = [SKSpriteNode spriteNodeWithImageNamed:@"Balao-Level1"];
    _balao.position = CGPointMake(_casa.position.x + _casa.size.width/1.9,
                                  _casa.position.y + _casa.size.height/5);
    _balao.zPosition = 2;
    _balao.hidden = YES;
    [self addChild:_balao];
    
//    Ações Balão
    
    SKAction *hide = [SKAction performSelector:@selector(hide) onTarget:self];
    SKAction *waitWhileShown = [SKAction waitForDuration:1];
    SKAction *waitWhileHidden = [SKAction waitForDuration:1];
    [_balao runAction:[SKAction repeatActionForever:
                       [SKAction sequence:@[waitWhileHidden,hide,waitWhileShown,hide]]] withKey:@"hideAction"];
    
//    Accelerometer
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.2; // tweak the sensitivity of intervals
    [_motionManager startAccelerometerUpdates];
    
//    Pinch recognizer
    
    zoomPinch = [[UIPinchGestureRecognizer alloc]
                       initWithTarget:self action:@selector(handleZoomFrom:)];
    [view addGestureRecognizer:zoomPinch];
}

-(void)handleZoomFrom:(UIPinchGestureRecognizer *)recognizer
{
    CGPoint anchorPoint = [recognizer locationInView:recognizer.view];
    anchorPoint = [self convertPointFromView:anchorPoint];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        // No code needed for zooming...
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint anchorPointInMySkNode = [_casa convertPoint:anchorPoint fromNode:self];
        
        [_casa setScale:(_casa.xScale * recognizer.scale)];
        
        CGPoint mySkNodeAnchorPointInScene = [self convertPoint:anchorPointInMySkNode fromNode:_casa];
        CGPoint translationOfAnchorInScene = CGPointSubtract(anchorPoint, mySkNodeAnchorPointInScene);
        
        _casa.position = CGPointAdd(_casa.position, translationOfAnchorInScene);
        
        recognizer.scale = 1.0;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // No code needed here for zooming...
        
    }
}

-(void)didEvaluateActions {
    if (_motionManager.accelerometerData.acceleration.x >= 0.7 &&
        _motionManager.accelerometerData.acceleration.x <= 1.1 &&
        _houseMove == YES) {
        SKAction *houseMove = [SKAction moveByX:1 y:0 duration:0.1];
        [_casa runAction:houseMove];
        [_balao runAction:houseMove];
    }
    if(_casa.position.x >= self.size.width - _casa.size.width/1.5) {
        if (_houseMove) {
            _houseMove = NO;
            [self nextLevel];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *test = [self nodeAtPoint:location];
        if ([test.name isEqualToString:@"cloud"]) {
            _cloud = YES;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        if (_cloud) {
            _cloudNode.position = CGPointMake(_cloudNode.position.x + location.x - previousLocation.x,
                                              _cloudNode.position.y);
            _explosionEmitter.position = _cloudNode.position;
        }
    }
    
    if ((_cloudNode.position.x > self.size.width - _cloudNode.size.width/2)) {
        _hideIt = NO;
        _balao.hidden = YES;
        SKTransition *transition = [SKTransition fadeWithDuration:0.5];
        
        SKScene *scene = [[LevelTwo alloc] initWithSize:self.size];
        
        [self.view presentScene:scene transition:transition];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _cloud = NO;
    
}

-(CGSize)proportion {
    
    float proportion = _backgroundTexture.size.width / self.size.width;
    CGSize correctSize = self.size;
    correctSize.height = self.size.height * proportion;
    correctSize.width = self.size.width;
    return correctSize;

}

-(void)hide {
    if (_hideIt) {
        _balao.hidden = !_balao.hidden;
    }
}

-(void)explosion:(CGPoint)position withName:(NSString*)name
{
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    _explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    _explosionEmitter.position = position;
    _explosionEmitter.zPosition = 2;
    [self addChild:_explosionEmitter];
}

-(void)rain {
    [self explosion:_cloudNode.position withName:@"rain"];
}

-(void)nextLevel {
    
    SKTransition *transition = [SKTransition fadeWithDuration:0.5];
    
    SKScene *scene = [[LevelTwo alloc] initWithSize:self.size];
    
    [self.view presentScene:scene transition:transition];
}

-(void)willMoveFromView:(SKView *)view {
    [_motionManager stopAccelerometerUpdates];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
