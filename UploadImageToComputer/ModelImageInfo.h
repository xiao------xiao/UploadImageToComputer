//
//  ModelImageInfo.h
//  UploadIphoneImageToComputer
//
//  Created by aliviya on 16/12/25.
//  Copyright © 2016年 coco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface ModelImageInfo : NSObject
@property (nonnull,nonatomic,copy)NSString *kFileName;
@property (nonnull,nonatomic,copy)NSString *kFileType;
@property (nonnull,nonatomic,retain) PHAsset *picAsset;
@property (nonnull,nonatomic,retain) NSData *imagedata;
@end
