# Coding Rule（精简）
## 基本
### 环境
- 操作系统：mac os<br>
- 开发软件：Xcode9.0以上<br>
### 命名简单规范（简明扼要，具体参照工程的举例模块书写方式）
#### 目录名称(业务模块)
English(中文后缀) 例：Login(登录)，Example(举例)
#### 类的名称
- 业务类：项目名称+模块名称+类型 例：<br>
ZJLoginController,ZJExampleController,ZJExampleModel,ZJExampleCell<br>
如果为二级界面，请升级模块名称 例：登录二级界面的注册功能(ZJLoginRegistController)<br>
- 个人工具类: 个人名字缩写+功能+类型 例：SBTextView
#### 方法名称
- 驼峰命名   例：
—(void)initContent{}  （加载视图方法）<br>
—(void)requestAction:(UIButton *) btn{} (点击按钮请求事件)
#### 对象命名
int count = 0;(计数器)
UIViewController *login = nil;(登录控制器)
UIButton *commitButton = nil; (提交按钮)
### 公共API设计规范
格式驼峰 ，简单明了 参照系统API  例：<br>
— (instancetype)initWithAccount:(NSString *)account password:(NSString *)password callback:(void(^)(BOOL success,id other))callback;
### git管理
- 请先下载SourceTree 进行版本管理。
- 远程仓库暂定为OSChina
- 及时提交和推送代码，基本1天要合并至少一次，新完成模块及时推送。
- 遇到冲突及时沟通
- 避免和他人写同一个模块
## 项目开始
1.APP采用object-c纯代码开发，末使用故事面板(storyboard)<br>
2.布局我们采用Masonry布局。<br>
3.设计模式 MVC。<br>
4.使用YTKNetworking（AFNetworking的再封装）为网络请求引擎。<br>https://github.com/yuantiku/YTKNetwork<br>
5.使用cocoapods进行库的统一管理，使用方便，清晰明了。<br>
6.使用git管理代码，团队开发，目前放在OSChina上，请下载SourceTree客户端进行git操作.<br>
7.数据库操作  <Realm><br>
## 目录结构
- 查看工程中试例 Login 和 Example
![image](https://github.com/pubin563783417/iOSCodingRule/blob/master/ScreenPhotos/目录1.png)<br>
![image](https://github.com/pubin563783417/iOSCodingRule/blob/master/ScreenPhotos/目录2.png)

## 常用代码块
- 自己设置在本地代码块中，加快开发效率<br>
https://github.com/pubin563783417/iOSCodingRule/blob/master/codeblock.txt

