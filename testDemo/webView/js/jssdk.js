var yw = {
    init: function(onResult) {
        if (window.WebViewJavascriptBridge) { return onResult(WebViewJavascriptBridge); }
        if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(onResult); }
        window.WVJBCallbacks = [onResult];
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'https://__bridge_loaded__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
    },

    scanQRCode: function(onResult) {
        window.WebViewJavascriptBridge.callHandler('QRScan', function(res) {
            onResult.success(res);
        });
    },

    chooseImage: function(param) {
        window.WebViewJavascriptBridge.callHandler('getImage', param.sourceType, function(res) {
            param.success(res);
        });
    },

    uploadImage: function(param) {
        var uploadParam = new Object();
        uploadParam.url = param.url;
        uploadParam.localId = param.localId;

        window.WebViewJavascriptBridge.callHandler('uploadImage', uploadParam, function(res) {
            if (res.status) {
                param.success(res);
            } else {
                param.fail(res);
            }
        });
    },

    showOptionMenu: function(param) {
        var menuArray = param.menuItems;
        for (var i = 0; i < menuArray.length; i++) {
            window.WebViewJavascriptBridge.registerHandler(
                menuArray[i].action,
                menuArray[i].callback
            );
        }

        window.WebViewJavascriptBridge.callHandler('showOptionMenu', menuArray, function(res) {
            console.log(JSON.stringify(res));
            if (res.status) {
                param.success();
            } else{
                param.fail();
            }
        });
    },

    hideOptionMenu: function() {
        window.WebViewJavascriptBridge.callHandler('hideOptionMenu', function(res) {

        });
    },

    setTitle: function(title) {
        window.WebViewJavascriptBridge.callHandler('setTitle', title, function(res) {

        });
    },

    openWindow: function(param) {
        var bridgeParam = new Object();
        bridgeParam.name = param.name;
        bridgeParam.extras = param.extras;

        window.WebViewJavascriptBridge.callHandler('openWindow', bridgeParam, function(res) {
            console.log(JSON.stringify(res));
            if (res.status) {
                param.success();
            } else{
                param.fail();
            }
        });
    },

    setRefresh: function(enabled) {
        window.WebViewJavascriptBridge.callHandler('setPullRefresh', enabled, function(res) {

        });
    },

    closeWindow: function() {
        window.WebViewJavascriptBridge.callHandler("_closePage");
    }
}

