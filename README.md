# WCImagePicker

[![WCImagePicker](https://img.shields.io/badge/build-passing-green.svg)]() [![WCImagePicker](https://img.shields.io/badge/pod-0.0.1-orange.svg)]() [![WCImagePicker](https://img.shields.io/badge/License-MIT-blue.svg)]() [![WCImagePicker](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]() [![WCImagePicker](https://img.shields.io/badge/support-iOS%208%2B-blue.svg)]() [![WCImagePicker](https://img.shields.io/badge/github-MeetDay-yellowgreen.svg)]()

简易好用的图片选择器



<div align=center>

![](https://github.com/MeetDay/WCImagePicker/blob/master/WCImagePickerDemo/WCImagePickerDemo/Assets/imagepicker_selection.PNG = 375*667)

![](https://github.com/MeetDay/WCImagePicker/blob/master/WCImagePickerDemo/WCImagePickerDemo/Assets/imagepicker_fullfill.PNG)

</div>



# Installation

- #### CocoaPods
  
  ​暂时没有，待完善后发布至CocoaPods


- #### 手动安装
  
  1. 下载WCImagePickerDemo。
  2. 将WCImagePicker文件夹中的源代码添加(拖放)到你的工程。
  3. 导入WCImagePicker.h都文件即可。

# Usage

#### WCImagePicker使用：

``` objective-c
WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
imagePicker.delegate = self;
imagePicker.mediaType = WCImagePickerImageTypeImage;
imagePicker.minimumNumberOfSelectionAsset = 1;
imagePicker.maximumNumberOfSelectionAsset = 9;

[self presentViewController:imagePicker animated:YES completion:nil];
```



#### 自定义WCImagePickerController样式：

如果想自定义WCImagePickerController的样式，你可以创建WCImagePickerAppearance实例，给其属性赋值。在实例化`WCImagePickerController`之前调用`setupImagePickerAppearance:`。

``` objective-c
+ (void)setupImagePickerAppearance:(WCImagePickerAppearance *)imagePickerAppearance;
```

WCImagePickerAppearance简单使用：

``` objective-c
WCImagePickerAppearance *imagePickerAppearance = [[WCImagePickerAppearance alloc] init];
imagePickerAppearance.cancelButtonText = @"退出";
imagePickerAppearance.finishedButtonDisableBackgroundColor = [UIColor grayColor];
[WCImagePickerController setupImagePickerAppearance:imagePickerAppearance];
```

设置更多可配置的属性，请查阅`WCImagePickerAppearance`。



#### WCImagePickerController的代理方法 (WCImagePickerControllerDelegate)

实现了`wc_imagePickerController:didFinishPickingAssets:`代理方法。当用户点击 “完成” (即完成图片选择)时，此代理方法被调用。

``` objective-c
/**
 选择完图片或视频后回调并回传选中的资源

 @param imagePicker 资源选择器
 @param assets 选中的资源
 */
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
  for (PHAsset *asset in assets) {
    // do something with the asset
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}
```

实现了`wc_imagePickerControllerDidCancel:`代理方法。当用户点击 “取消” 时，此代理方法被调用。

``` objective-c
/**
 点击取消后调用

 @param imagePicker 资源选择器
 */
- (void)wc_imagePickerControllerDidCancel:(WCImagePickerController *)imagePicker {
  // 
  [self dismissViewControllerAnimated:YES completion:nil];
}
```

实现以下代理方法，能处理用户选择Asset的选中状态。

``` objective-c
/**
 判断是否应该选中该资源

 @param imagePicker 资源选择器
 @param asset 资源(图片或视频)
 @return 是否应该选中
 */
- (BOOL)wc_imagePickerController:(WCImagePickerController *)imagePicker shouldSelectAsset:(PHAsset *)asset;

/**
 asset选中时回调

 @param imagePicker 资源选择器
 @param asset 资源(图片或视频)
 */
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didSelectAsset:(PHAsset *)asset;

/**
 asset取消选中时回调

 @param imagePicker 资源选择器
 @param asset 资源(图片或视频)
 */
- (void)wc_imagePickerController:(WCImagePickerController *)imagePicker didDeselectAsset:(PHAsset *)asset;
```



#### WCImagePickerController filter option

**只选择图片**

``` objective-c
WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
imagePicker.delegate = self;
imagePicker.mediaType = WCImagePickerImageTypeImage;
imagePicker.minimumNumberOfSelectionAsset = 1;
imagePicker.maximumNumberOfSelectionAsset = 9;
```

**只选择视频**

``` objective-c
WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
imagePicker.delegate = self;
imagePicker.mediaType = WCImagePickerImageTypeVideo;
imagePicker.minimumNumberOfSelectionAsset = 1;
imagePicker.maximumNumberOfSelectionAsset = 3;
```

**选择图片和视频**

``` objective-c
WCImagePickerController *imagePicker = [[WCImagePickerController alloc] init];
imagePicker.delegate = self;
imagePicker.mediaType = WCImagePickerImageTypeAny;
imagePicker.minimumNumberOfSelectionAsset = 1;
imagePicker.maximumNumberOfSelectionAsset = 20;
```

**Grid Size**

可用`numberOfColumnsInPortrait`和`numberOfColumnsInLandscape`改变grid size。

``` objective-c
// grid size 默认值
imagePicker.numberOfColumnsInPortrait = 4;
imagePicker.numberOfColumnsInLandscape = 7;
```

**选中资源(图片或视频)达到最大数量时未选中资源是否显示遮罩**

``` objective-c
// 默认：YES
imagePicker.showAssetMaskWhenMaximumLimitReached = YES;
```

**选中资源(图片或视频)达到最大数量时是否显示警示弹窗**

``` objective-c
// 默认：YES
imagePicker.showWarningAlertWhenMaximumLimitReached = YES;
```

**是否显示没有资源(图片或视频)的相册**

``` objective-c
// 默认：NO
imagePicker.showPhotoAlbumWithoutAssetResources = NO;
```

**更换相册时是否移除已选中的资源(图片或视频)**

``` objective-c
// 默认：YES
imagePicker.shouldRemoveAllSelectedAssetWhenAlbumChanged = YES;
```

**是否允许手指在屏幕上滑动时选中资源(图片或视频)**

``` objective-c
// 默认：NO
imagePicker.fingerMovingToAssetForSelectionEnable = NO;
```

# Change Log

待完善

# Contact

- Github：[MeetDay](https://github.com/MeetDay/WCImagePicker)
- 邮箱：1594076579@qq.com 或 crazyitcoder@gmail.com
- QQ：1594076579

# LICENSE

- 详情见 [LICENSE](https://github.com/MeetDay/WCImagePicker/blob/master/LICENSE) 文件。