//
//  ViewController.m
//  UploadIphoneImageToComputer
//
//  Created by aliviya on 16/12/22.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <AFNetworking.h>
#import "ModelImageInfo.h"
#define SCREENWIDTH self.view.frame.size.width
#define SCREENHEIGHT self.view.frame.size.height

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    NSMutableArray *assetArray; //存储imageInfo
    
    int picIndex ; //检索的图片index
    UILabel *lblTips;  //显示当前上传状态
    
    UILabel *lblCurrentIndex; //当前检索的位置显示
}

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    picIndex = 0;
    assetArray = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        // 这里便是无访问权限
        NSLog(@"无访问权限");
    }
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 150, 100)];
    
    
    [testBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    [testBtn setTitle:@"上传图片和视频" forState:UIControlStateNormal];

    [testBtn addTarget:self action:@selector(testUploadPictureInAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    
    lblTips = [[UILabel alloc] initWithFrame:CGRectMake( 0, SCREENHEIGHT-40, SCREENWIDTH, 21)];

    lblTips.textColor = [UIColor greenColor];
    lblTips.text =@"空闲中";
    
    [self.view addSubview:lblTips];
    
    lblCurrentIndex = [[UILabel alloc] initWithFrame:CGRectMake( 0, 10, SCREENWIDTH, 21)];
    lblCurrentIndex.textColor = [UIColor blackColor];
    lblCurrentIndex.font = [UIFont systemFontOfSize:12];
    lblCurrentIndex.text =[NSString stringWithFormat:@"idx -- %i",picIndex];
    
    [self.view addSubview:lblCurrentIndex];
    
    
}

- (IBAction)testUploadPictureInAlbum:(id)sender {
    lblTips.text =@"正在遍历相册";
    lblTips.textColor = [UIColor redColor];
    lblCurrentIndex.text =[NSString stringWithFormat:@"idx -- %i",picIndex];

    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:[PHFetchOptions new]] ;
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        NSLog(@"assetCollection.localizedTitle ---%@",assetCollection.localizedTitle);
        if ([assetCollection.localizedTitle isEqualToString:@"All Photos"])  {
            PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
            [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx >=picIndex+10){
                    *stop = YES;
                }
                if (idx>=picIndex&&idx<picIndex+10) {
                NSLog(@"idx  %lu",(unsigned long)idx);
                    
                    PHAsset *asset = (PHAsset *)obj;
                
                    if (asset.mediaType == PHAssetMediaTypeImage) {
                        
                        BOOL inlocal = [self checkIfInCloud:asset];
                        if (inlocal) {
                            NSLog(@"本地有资源");

                        }else{
                            NSLog(@"本地没有资源");

                        }
                    }else if(asset.mediaType==PHAssetMediaTypeVideo){
                        
                        
                        if (asset.mediaSubtypes==PHAssetMediaSubtypeVideoStreamed||asset.mediaSubtypes==PHAssetMediaSubtypeVideoHighFrameRate||asset.mediaSubtypes==PHAssetMediaSubtypeVideoTimelapse||asset.mediaSubtypes ==PHAssetMediaSubtypeNone) {
                         
                            
                            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                            options.version = PHVideoRequestOptionsVersionOriginal;
                            
                            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
                                NSLog(@"current thread --- %@",[NSThread currentThread]);
                                if ([avasset isKindOfClass:[AVURLAsset class]]) {
                                    NSURL *URL = [(AVURLAsset *)avasset URL];
                                    
                                    // use URL to get file content
                                    NSLog(@"ddddd---%@",URL.absoluteString);
                                    
                                    NSData *videoData = [NSData dataWithContentsOfURL:URL];
                                    NSLog(@"video info ---%@",[info description]);
                                    
                                    
                                    NSString *fileName = [[URL.absoluteString componentsSeparatedByString:@"/"] lastObject];
                                    
                                    ModelImageInfo *videoInfo = [[ModelImageInfo alloc] init];
                                    
                                    videoInfo.kFileName = fileName;
                                    videoInfo.kFileType = @"video/quicktime";
                                    videoInfo.picAsset = asset;
                                    videoInfo.imagedata = videoData;
                                    
                                    [assetArray addObject:videoInfo];
                                    NSLog(@"assetArray addObject:videoInfo--- %@",[NSDate date]);
                                }
                            }];
                        }
                    }
                }
             
            }];
        }
    }];
    
 
    [self performSelector:@selector(uploadImageAndVideo) withObject:nil afterDelay:1.0f];
}
-(void)uploadImageAndVideo{
    picIndex+=10;
    NSLog(@"testuploadImage--- %@",[NSDate date]);
    
    [self testuploadImage];
}
//查看图片是否在本地
-(BOOL)checkIfInCloud:(PHAsset *)asset{
  
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
        //本地的图片并且没有和icloud 共享
        if (isInLocalAblum) {
            
            NSLog(@"info image ---%@",[info description]);
            NSString *filetype = info[@"PHImageFileUTIKey"];
            NSURL *filePath= info[@"PHImageFileURLKey"];
            
           NSString *fileName = [[filePath.absoluteString componentsSeparatedByString:@"/"] lastObject];
            
            ModelImageInfo *imageInfo = [[ModelImageInfo alloc] init];
            
            imageInfo.kFileName = fileName;
            imageInfo.kFileType = [filetype isEqualToString:@"public.jpeg"]?@"image/jpeg":@"image/png";
            imageInfo.picAsset = asset;
            imageInfo.imagedata = imageData;
            
            [assetArray addObject:imageInfo];
        }
       
    }];
    return isInLocalAblum;
}
//上传图片
-(void)testuploadImage{

   
    if(assetArray.count==0){
        lblTips.text =@"空闲中";
        lblTips.textColor = [UIColor greenColor];
        return;
    }
     lblTips.text =@"正在上传";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager] ;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    

    [manager POST:@"http://192.168.1.104:8081/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (ModelImageInfo *modImage in assetArray) {
            [formData appendPartWithFileData:modImage.imagedata
                                        name:@"photos"
                                    fileName:modImage.kFileName
                                    mimeType:modImage.kFileType];
        }
       

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        float pecentvalue =uploadProgress.completedUnitCount*100/ uploadProgress.totalUnitCount;
        
        NSString *string = [NSString stringWithFormat:@"上传进度 %f %%",pecentvalue];
        NSLog(@"%@",string);
        lblTips.text =string;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功");
        lblTips.text =@"上传成功，等待删除原图像";
        [self testDeletePicturesUpload];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         lblTips.text =@"上传失败";
        NSLog(@"失败----error --%@",[error description]);
    }];
    
    
}
//删除上传完的照片
-(void)testDeletePicturesUpload{
    lblTips.text = @"正在删除原图...";
    //删除所有上传完的图片
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ModelImageInfo *model in assetArray){
        [array addObject:model.picAsset];
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //获取相册的最后一张照片
        
        [PHAssetChangeRequest deleteAssets:array];
        
        
    } completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Error: %@", error);
        if (success) {
             lblTips.text =@"空闲中";
            lblTips.textColor = [UIColor greenColor];
            NSLog(@"所有上传完的图片都上传完了－－－");
            picIndex-=assetArray.count;
            [assetArray removeAllObjects];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
