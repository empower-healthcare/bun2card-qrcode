package jp.xaas.bun2card.plugin.barcodereader;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

/**
 * バーコードリーダーPluginクラス
 * @author 9000516
 */
public class BarcodeReaderPlugin extends CordovaPlugin {

	private CallbackContext callbackContext;
    private static final String TAG = BarcodeReaderPlugin.class.getSimpleName();
    private static final String SCAN_INTENT = "jp.xaas.bun2card.plugin.barcodereader.SCAN";
    private static final int REQUEST_CODE = 10001;

    /**
     * @param action
     * openQRReader バーコードリーダーを起動
     * @param args
     * INDEX   ARGUMENT
     *  0       camera position(１：背面カメラ／２：前面カメラ)
     *  1       typeQRCode
     *  2       typeCode39
     *  3       typeCode39Mod43 ※設定無効
     *  4       typeEAN13
     *  5       typeEAN8
     *  6       typeUPCE
     *  7       typeCode93
     *  8       typeCode128
     */
    @Override
    public boolean execute(String action,
                           JSONArray args,
                           CallbackContext callbackContext) throws JSONException {
        try {
            this.callbackContext = callbackContext;
            if ("openQRReader".equals(action)) {
                openQRReader(args);
            } else {
                this.callbackContext.error("action is not exists.(" + action + ")");
            }
            return true;
        } catch (Exception e) {
        	e.printStackTrace();
            Log.e(TAG, e.getMessage(), e);
            this.callbackContext.error(e.getMessage());
            return false;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                this.callbackContext.success(intent.getStringExtra("barcode"));
            } else if (resultCode == Activity.RESULT_CANCELED) {
                String nullStr = null;
                this.callbackContext.success(nullStr);//引数なしだと「OK」と値が返るため、nullを設定
            } else {
                this.callbackContext.error(intent.getStringExtra("error"));
            }
        }
    }

    /**
     * QRコードリーダー画面を表示します。
     * @param args
     */
    private void openQRReader(JSONArray args) {
        Intent intent = new Intent(SCAN_INTENT);

        boolean isFrontCamera   = true;
        try {
            if (args.length() > 0) {
                int num = args.getInt(0);
                if (num == 1) {
                    isFrontCamera = false;
                }
            }
        } catch (Exception e) {
        }
        boolean typeQRCode      = getBarcodeType(args, 1);
        // QRコード以外については認識率が低いため、読み取り範囲の限定などの対応が必要
        boolean typeCode39      = getBarcodeType(args, 2);
        boolean typeCode39Mod43 = getBarcodeType(args, 3);
        boolean typeEAN13       = getBarcodeType(args, 4);
        boolean typeEAN8        = getBarcodeType(args, 5);
        boolean typeUPCE        = getBarcodeType(args, 6);
        boolean typeCode93      = getBarcodeType(args, 7);
        boolean typeCode128     = getBarcodeType(args, 8);
        if (!typeQRCode &&
            !typeCode39 &&
            !typeCode39Mod43 &&
            !typeEAN13 &&
            !typeEAN8 &&
            !typeUPCE &&
            !typeCode93 &&
            !typeCode128) {
            typeQRCode = true;
        }
        intent.putExtra("FrontCamera", isFrontCamera);
        intent.putExtra("BarcodeTypeQRCode", typeQRCode);
        intent.putExtra("BarcodeTypeCode39", typeCode39);
        intent.putExtra("BarcodeTypeCode39Mod43", typeCode39Mod43);
        intent.putExtra("BarcodeTypeEAN13", typeEAN13);
        intent.putExtra("BarcodeTypeEAN8", typeEAN8);
        intent.putExtra("BarcodeTypeUPCE", typeUPCE);
        intent.putExtra("BarcodeTypeCode93", typeCode93);
        intent.putExtra("BarcodeTypeCode128", typeCode128);

        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setPackage(this.cordova.getActivity().getApplicationContext().getPackageName());
        this.cordova.startActivityForResult((CordovaPlugin) this, intent, REQUEST_CODE);
    }

    /**
     * 該当インデックスのバーコードタイプの読取の可否を取得します。
     * @param args
     * @param index
     * @return TRUE：読取対象／FALSE：読取対象外
     */
    private boolean getBarcodeType(JSONArray args, int index) {
        try {
            if (args.length() > index) {
                return args.getBoolean(index);
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }
}
