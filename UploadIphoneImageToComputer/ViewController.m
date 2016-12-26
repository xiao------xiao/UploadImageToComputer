//
//  ViewController.m
//  UploadIphoneImageToComputer
//
//  Created by aliviya on 16/12/22.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "CustomCollectionViewCell.h"
#import <AFNetworking.h>
#import "ModelImageInfo.h"
#define SCREENWIDTH self.view.frame.size.width
#define SCREENHEIGHT self.view.frame.size.height

@interface ViewController ()<UICollectionViewDelegate ,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UICollectionViewFlowLayout *flowLayout;
    UICollectionView *_collectionView;
    UILabel *_urlTextView;
    UIImageView *_imageview ;
    
    NSMutableArray *assetArray; //存储imageInfo
    int picIndex ;
    UILabel *lblTips;
    
    UILabel *lblCurrentIndex;
}

@end

@implementation ViewController
// 注意const的位置
static NSString *const cellId = @"CustomCollectionViewCell";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";


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
    
//    [self loadCollectionView];
//    [self loadData];
//
    //test upload video
//    UIButton *uploadMovieBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 150, 100)];
//    
//    
//    [uploadMovieBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    
//    [uploadMovieBtn setTitle:@"上传视频demo" forState:UIControlStateNormal];
//    
//    [uploadMovieBtn addTarget:self action:@selector(testUploadMovie) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:uploadMovieBtn];
    
    
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
//测试上传视频
-(void)testUploadMovie{
    //    [assetArray removeAllObjects];
    
//    if(assetArray.count==0){
//        return;
//    }
  

//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager] ;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    NSString *videoPath= [[NSBundle mainBundle] pathForResource:@"hello" ofType:@"m4v"];  // 这里直接强制
//    NSData *videoData = [[NSData alloc] initWithContentsOfFile:videoPath];
//    
//    
//    [manager POST:@"http://192.168.1.104:8081/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        
//        if(videoData){
//            [formData appendPartWithFileData:videoData
//                                        name:@"photos"
//                                    fileName:@"video1.m4v"
//                                    mimeType:@"video/x-m4v"];
//        
//        
//        }
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        float pecentvalue =uploadProgress.completedUnitCount*100/ uploadProgress.totalUnitCount;
//        NSLog(@"上传进度 %f %%",pecentvalue);
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"成功");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"失败----error --%@",[error description]);
//    }];
    
    
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
- (void)loadCollectionView
{
    flowLayout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
    //列距
    flowLayout.minimumInteritemSpacing = 30;
    //行距
    flowLayout.minimumLineSpacing = 40;
    //item大大小
    flowLayout.itemSize = CGSizeMake((SCREENWIDTH-60)/3, 200);
    //初始化
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor orangeColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    // 注册cell、sectionHeader、sectionFooter
    [_collectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellId];
//    [_collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
}
#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        NSLog(@"照片名%@", [asset valueForKey:@"filename"]);
        [assets addObject:asset];
    }];
    
    return assets;
}
-(void)loadData{
    //创建可变数组,存储资源文件
//    _array = [NSMutableArray array];
//    
//    [_array addObject:@"1"];
//    [_collectionView reloadData];
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    cell.imageview.image = [UIImage imageNamed:@"hello.png"];
    
    return cell;
}




#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){100,100};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){SCREENWIDTH,44};
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){SCREENWIDTH,22};
}




#pragma mark ---- UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    
//    cell.backgroundColor = [UIColor greenColor];
}


// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


//// 长按某item，弹出copy和paste的菜单
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//// 使copy和paste有效
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
//{
//    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"])
//    {
//        return YES;
//    }
//    
//    return NO;
//}
//
////
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
//{
//    if([NSStringFromSelector(action) isEqualToString:@"copy:"])
//    {
//        //        NSLog(@"-------------执行拷贝-------------");
//        [_collectionView performBatchUpdates:^{
//            [_section0Array removeObjectAtIndex:indexPath.row];
//            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
//        } completion:nil];
//    }
//    else if([NSStringFromSelector(action) isEqualToString:@"paste:"])
//    {
//        NSLog(@"-------------执行粘贴-------------");
//    }
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
