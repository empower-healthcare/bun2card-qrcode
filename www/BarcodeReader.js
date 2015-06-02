var BarcodeReader = function(){};

BarcodeReader.prototype.scan =  function(successCallback, errorCallback, options) {
    
    function onSuccess(data) {
        console.log("DATA=" + data);
        if (typeof successCallback === 'function') {
            successCallback();
        }
    }

    function onError() {
        if (typeof errorCallback === 'function') {
            errorCallback();
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
