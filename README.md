# UploadIphoneImageToComputer
通过检索iphone手机相册里的图片和视频并上传图片和视频到服务器,类似于照片里的同步功能，通过Mac电脑里的照片应用下载Iphone手机图片和视频是不是很慢呢，通过这个demo可以实现1分钟同步所有Iphone图片和视频，还能删除手机里的原图，大大缩减手机内存。

基本信息:Xcode 8.1  基本库 Photos.framework 

1>首先要开一个本机服务器，通过与本机服务器的连接来实现图片或视频的上传，我采取的方法是安装nodejs，方便快捷，怎么安装就不说了,网上一大堆，项目中有我的本地nodejs文件，可以直接拿来用，uploadMultImage.js

2>开启服务器 ，具体操作:
      在终端中，cd 到nodejs 文件存储目录，然后 node  uploadMultImage.js 
      终端会给出 应用实例，访问地址为 http://:::8081 信息，这是本地服务器已经开启了，按住control ＋c 键可以关闭服务器
   
3>服务器开启了，接下来就是客户端了
      代码中，需要先pod下来 AFNetworking，然后改写代码中连接的url为你本机的ip地址 一般是 192.168.1.xxx 格式 

4>然后就可以装载到手机里运行了
      可以不用连接电脑 ，前提是手机和服务器要在同一个局域网里,点击应用里的上传按钮就可以了，上传成功后还会提示你是否要删除icloud 里面的原图，可以选择删除或者保存。

      4.1> 默认只会上传本地有原资源的图片或视频，不回下载icloud 中没有下载下来的图片，如果想下载可以改写代码中
      PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
      option.networkAccessAllowed = NO;   配置为NO 表示不从icloud 下载，YES 表示下载

      4.2> 为了减小服务器的压力和连接时长考虑，每次点击按钮时只检索10张上传，下次会从上次检索末尾重新检索10张，不用担心重复检索的问题




