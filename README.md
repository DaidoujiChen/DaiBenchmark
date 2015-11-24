# DaiBenchmark

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiBanchmark.gif)

這是一個好玩的專案, 可以看著球掉下來, 會有紓壓的感覺, 上班的時候可以開著當作螢幕保護程式, 很吃電! 哈哈. 

也很可以看一下自己的裝置可以累積到幾顆球, 當 FPS 降低時, 靠著邊緣的球會消失, 因此, 球是無法持續累積的.

其中, 

 - 球掉下來的效果是 `UIDynamicAnimator`
 - FPS 計算則是用 `CADisplayLink`
 - 陀螺儀是用 `CMMotionManager`

都是內建的工具, 有興趣的話可以看看, `FPSMeter` 是一個拉出來的組件, 可以方便的去監看當前 FPS 的數字, 喜歡的話可以拿去用. :)

Daidouji

daidoujichen@gmail.com
