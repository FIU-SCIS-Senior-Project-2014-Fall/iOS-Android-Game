//
//  MessageWriter.h
//  Mod10
//
//  Created by Lorenzo Castillo on 9/28/14.
//  Copyright 2014 Lorenzo Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageWriter : NSObject {
    NSMutableData * _data;
}

@property (retain, readonly) NSMutableData * data;

- (void)writeByte:(unsigned char)value;
- (void)writeInt:(long)value;
- (void)writeString:(NSString *)value;

@end
