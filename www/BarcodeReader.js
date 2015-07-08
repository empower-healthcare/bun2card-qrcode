var BarcodeReader = function(){};

BarcodeReader.prototype.scan =  function(successCallback, errorCallback, options) {
    
    function onSuccess(data) {
        if (typeof successCallback === 'function') {
            successCallback(data);
        }
    }

    function onError(msg) {
        if (typeof errorCallback === 'function') {
            errorCallback(msg);
        }
    }
    cordova.exec(onSuccess, onError, "BarcodeReaderPlugin", "openQRReader", [1]);
}

BarcodeReader.install = function () {
  window.barcodeReader = new BarcodeReader();
  return window.barcodeReader;
};

if (typeof window.cordova !== 'undefined') {
    console.log('install BarcodeReader plugins');
    cordova.addConstructor(BarcodeReader.install);
} else {
   console.log('No cordova.');
}
