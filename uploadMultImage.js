
var express = require('express');
var app = express();

var fs = require("fs");
// var multipart = require('connect-multiparty');
// var multipartMiddleware = multipart();
// var bodyParser = require('body-parser');
var multer  = require('multer');
var createFolder = function(folder){
    try{
        fs.accessSync(folder); 
    }catch(e){
        fs.mkdirSync(folder);
    }  
};

var uploadFolder = './uploads/';

createFolder(uploadFolder);

// 通过 filename 属性定制
var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadFolder);    // 保存的路径，备注：需要自己创建
    },
    filename: function (req, file, cb) {
        // 将保存文件名设置为 字段名 + 时间戳，比如 logo-1478521468943
        cb(null,Date.now()+'-'+file.originalname);
        
    }
});

// 通过 storage 选项来对 上传行为 进行定制化
var upload = multer({ storage: storage })

app.get('/index.html', function (req, res) {
   res.sendFile( __dirname + "/" + "index.html" );
});
//多附件上传  
//注意上传界面中的 <input type="file" name="photos"/>中的name必须是下面代码中指定的名  
app.post('/upload', upload.array('photos', 12), function (req, res, next) {  
  // req.files is array of `photos` files   
  // req.body will contain the text fields, if there were any   
  
  console.log(req.files);  
  
  //res.end(req.file + "<br/><br/>" + req.body);  
  res.end("aaaaa");  
  
});
var server = app.listen(8081, function () {

  var host = server.address().address
  var port = server.address().port

  console.log("应用实例，访问地址为 http://%s:%s", host, port)

});
server.setTimeout(0); 
