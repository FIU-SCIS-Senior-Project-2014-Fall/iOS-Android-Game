//
//  GCDatabase.m
//  Mod10
//
//  Created by Lorenzo Castillo on 7/26/14.
//  Copyright (c) 2014 Lorenzo Castillo. All rights reserved.
//

#import "GCDatabase.h"

NSString * pathForFile(NSString *filename) {
    // 1
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    // 2
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 3
    return [documentsDirectory
            stringByAppendingPathComponent:filename];
}
id loadData(NSString * filename) {
    // 4
    NSString *filePath = pathForFile(filename);
    // 5
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // 6
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        // 7
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        // 8
        id retval = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
        return retval;
    }
    return nil;
}

void saveData(id theData, NSString *filename) {
    // 9
    NSMutableData *data = [[NSMutableData alloc] init];
    // 10
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // 11
    [archiver encodeObject:theData forKey:@"Data"];
    [archiver finishEncoding];
    // 12
    [data writeToFile:pathForFile(filename) atomically:YES];
}
