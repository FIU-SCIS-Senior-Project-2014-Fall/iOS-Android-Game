//
//  Constants.h
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#ifndef Mod10_Constants_h
#define Mod10_Constants_h


#define MAX_MOVES 1
#define MAX_TIME 2
#define ROWS 5
#define COLUMNS 5

typedef enum {
    kNoMode,
    kTimedMode,
    kMovesMode
} GameModes;

typedef enum {
    kChangingScenes,
    kGameOverScene,
    kMenuScene,
    kGameLayerScene
} SceneStates;

#endif
