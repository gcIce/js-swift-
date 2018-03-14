# js-swift-
JS调用原生接口，代码执行一些操作后，通过回调返回参数给JS

创建的导航栏按钮 刷新一下 点击无效解决方法
将WebViewJavascriptBridge_JS.m中的js代码放在h5中
然后WKWebViewJavascriptBridge.m  里这个方法[_base injectJavascriptFile];注释了 
每次就不用注入JS脚本了
