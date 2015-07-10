package jp.xaas.bun2card.plugin.barcodereader;

import java.io.IOException;
import java.util.List;
import java.util.Timer;

import jp.xaas.bun2card.plugin.FakeR;
import android.app.Activity;
import android.content.Intent;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.PreviewCallback;
import android.os.Bundle;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Button;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;

/**
 * バーコードリーダーActivityクラス
 * @author 9000516
 */
public class BarcodeReaderActivity extends Activity
                                   implements SurfaceHolder.Callback, AutoFocusCallback, PreviewCallback {

    private static final String TAG = BarcodeReaderActivity.class.getSimpleName();

    // カメラ
    private Camera mCamera;
    private boolean isFrontCamera = true;
    private int mCameraIndex = -1;

    // カメラプレビュー
    private SurfaceView mSurfaceView;
    private boolean isSurfaceCreated = false;

    // フォーカス
    private Timer mTimerFocus;

    // チェックバーコード
    private boolean isBarcodeTypeQRCode = false;
    private boolean isBarcodeTypeCode39 = false;
    private boolean isBarcodeTypeEAN13 = false;
    private boolean isBarcodeTypeEAN8 = false;
    private boolean isBarcodeTypeUPCE = false;
    private boolean isBarcodeTypeCode93 = false;
    private boolean isBarcodeTypeCode128 = false;
    private FakeR fakeR;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        fakeR = new FakeR(this);

        //setContentView(R.layout.cdv_br_activity_scan);
        setContentView(fakeR.getId("layout", "cdv_br_activity_scan"));
        
        // キャンセルボタンのイベントリスナー設定
        // Button buttonCancel =(Button)findViewById(R.id.buttonCancel);
        Button buttonCancel =(Button)findViewById(fakeR.getId("id", "buttonCancel"));
        buttonCancel.setOnClickListener(
            new View.OnClickListener(){
                @Override
                public void onClick(View v) {
                    buttonCancel_OnClickListener(v);
                }
            });

        // パラメータの取得
        Intent intent = getIntent();
        isFrontCamera = intent.getBooleanExtra("FrontCamera", true);
        // Code39Mod43はZxingがサポートしていない
        isBarcodeTypeQRCode = intent.getBooleanExtra("BarcodeTypeQRCode", false);
        isBarcodeTypeCode39 = intent.getBooleanExtra("BarcodeTypeCode39", false);
        isBarcodeTypeEAN13 = intent.getBooleanExtra("BarcodeTypeEAN13", false);
        isBarcodeTypeEAN8 = intent.getBooleanExtra("BarcodeTypeEAN8", false);
        isBarcodeTypeUPCE = intent.getBooleanExtra("BarcodeTypeUPCE", false);
        isBarcodeTypeCode93 = intent.getBooleanExtra("BarcodeTypeCode93", false);
        isBarcodeTypeCode128 = intent.getBooleanExtra("BarcodeTypeCode128", false);
//        isBarcodeTypeQRCode = true;
//        isBarcodeTypeCode39 = true;
//        isBarcodeTypeEAN13 = true;
//        isBarcodeTypeEAN8 = true;
//        isBarcodeTypeUPCE = true;
//        isBarcodeTypeCode93 = true;
//        isBarcodeTypeCode128 = true;

    }

    @Override
    protected void onResume() {
        super.onResume();
        // mSurfaceView = (SurfaceView) findViewById(R.id.preview);
        mSurfaceView = (SurfaceView) findViewById(fakeR.getId("id", "preview"));
        SurfaceHolder holder = mSurfaceView.getHolder();
        if (isSurfaceCreated) {
            openCamera(holder);
        } else {
            holder.addCallback(this);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        closeCamera();
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        isSurfaceCreated = true;
        openCamera(holder);
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        isSurfaceCreated = false;
    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        if (mCamera != null) {
            int width = mCamera.getParameters().getPreviewSize().width;
            int height = mCamera.getParameters().getPreviewSize().height;
            PlanarYUVLuminanceSource source =
                    new PlanarYUVLuminanceSource(data,
                                                 width,
                                                 height,
                                                 0,
                                                 0,
                                                 width,
                                                 height,
                                                 isFrontCamera);
            if (source != null) {
                BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
                MultiFormatReader multiFormatReader = new MultiFormatReader();
                try {
                    Result rawResult = multiFormatReader.decode(bitmap);
                    if (isTargetBarcodeFormat(rawResult.getBarcodeFormat())) {
                        // QRコードの場合は終了

//                        // 効果音を鳴らす
//                        Uri uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
//                        Ringtone ringtone = RingtoneManager.getRingtone(getApplicationContext(), uri);
//                        ringtone.play();
//                        try {
//                            Thread.sleep(1000);// すぐにstopが実行されると効果音が鳴らないため、1秒間sleep。
//                        } catch(InterruptedException e) {
//                            // 特に何もしない
//                        }
//                        ringtone.stop();

                        // 終了
                        closeCamera();
                        Intent intent = new Intent();
                        intent.putExtra("barcode", rawResult.getText());
                        close(RESULT_OK, intent);
                    } else {
                        // QRコード以外の場合は読み取りを続ける
                        mCamera.setOneShotPreviewCallback(this);
                    }
                } catch (ReaderException e) {
                    // 読み取り失敗の場合は読み取りを続ける
                    mCamera.setOneShotPreviewCallback(this);
                }
            }
        }
    }

    @Override
    public void onAutoFocus(boolean success, Camera camera) {
        if (success) {
            mCamera.setOneShotPreviewCallback(this);
        }
    }

    /**
     * キャンセルボタンクリック処理
     * @param v
     */
    private void buttonCancel_OnClickListener(View v) {
        close(RESULT_CANCELED, null);
    }

    /**
     * カメラ始動処理
     * @param holder
     * @throws IOException
     */
    private void openCamera(SurfaceHolder holder) {
        if (mCamera == null) {
            int backCameraId = -1;
            int frontCameraId = -1;
            int countCameras = Camera.getNumberOfCameras();
            CameraInfo checkCameraInfo = new CameraInfo();
            for(int i = 0; i < countCameras; i++) {
                Camera.getCameraInfo(i, checkCameraInfo);
                if (checkCameraInfo.facing == CameraInfo.CAMERA_FACING_BACK) {
                    backCameraId = i;
                } else if (checkCameraInfo.facing == CameraInfo.CAMERA_FACING_FRONT) {
                    frontCameraId = i;
                }
            }
            try {
                if (isFrontCamera && frontCameraId >= 0) {
                    mCamera = Camera.open(frontCameraId);
                    mCameraIndex = frontCameraId;
                } else if (backCameraId >= 0) {
                    isFrontCamera = false;
                    mCamera = Camera.open(backCameraId);
                    mCameraIndex = backCameraId;
                }
                if (mCamera == null) {
                    closeError("適切なカメラが見つかりませんでした。");
                    return;
                }

            } catch(RuntimeException e) {
                closeError(e);
                return;
            }
        }

        try {
            mCamera.setPreviewDisplay(holder);
        } catch(IOException e) {
            closeError(e);
            return;
        }

        // プレビュー方向設定
        CameraInfo cameraInfo = new CameraInfo();
        Camera.getCameraInfo(mCameraIndex, cameraInfo);
        int rotation = getWindowManager().getDefaultDisplay().getRotation();
        int degrees = 0;
        switch(rotation) {
            case Surface.ROTATION_0:
                degrees = 0;break;
            case Surface.ROTATION_90:
                degrees = 90;break;
            case Surface.ROTATION_180:
                degrees = 180;break;
            case Surface.ROTATION_270:
                degrees = 270;break;
        }
        int result;
        if (isFrontCamera) {
            result = (cameraInfo.orientation + degrees) % 360;
            result = (360 - result) % 360;
        } else {
            result = (cameraInfo.orientation - degrees + 360) % 360;
        }
        mCamera.setDisplayOrientation(result);

        // プレビューサイズ設定
        Camera.Parameters params = mCamera.getParameters();
        List<Camera.Size> sizes = params.getSupportedPreviewSizes();
        Camera.Size size = sizes.get(0);
        params.setPreviewSize(size.width, size.height);
        mCamera.setParameters(params);

        mCamera.startPreview();
        try {
        	Thread.sleep(1000);
        	mCamera.autoFocus(null);
        } catch (InterruptedException e) {
        	;
        }
        // カメラオートフォーカス設定
        /*
        if (mTimerFocus == null) {
            mTimerFocus = new Timer(false);
            mTimerFocus.schedule(new TimerTask() {
                @Override
                public void run() {
                	try {
                		mCamera.cancelAutoFocus();
                		mCamera.autoFocus(null);
                	} catch (Exception e) {
                		//
                		Log.e(TAG, e.getMessage());
                	}
                }
            }, 500, 1000); // 1秒間隔でオートフォーカス
        }
        */
        mCamera.setOneShotPreviewCallback(this);
    }

    /**
     * カメラ終了処理
     */
    private void closeCamera() {
        if (mTimerFocus != null) {
            mTimerFocus.cancel();
            mTimerFocus = null;
        }
        if (mCamera != null) {
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
        }
    }


    /**
     * バーコードリーダー終了処理
     * @param resultCode
     * @param data
     */
    private void close(int resultCode, Intent data) {
        setResult(resultCode, data);
        finish();
    }

    /**
     * Exceptionによるバーコードリーダー終了処理
     * @param e
     */
    private void closeError(Exception e) {
        Log.e(TAG, e.getMessage(), e);
        closeError(e.getMessage());
    }

    /**
     * エラーによるバーコードリーダー終了処理
     * @param errorMessage
     */
    private void closeError(String errorMessage) {
        Intent intent = new Intent();
        intent.putExtra("error", errorMessage);
        close(999, intent);
    }

    /**
     * 指定のバーコードフォーマットが処理対象か確認
     * @param format
     * @return TRUE：処理対象／FALSE：処理対象外
     */
    private boolean isTargetBarcodeFormat(BarcodeFormat format) {
        if ((isBarcodeTypeQRCode && BarcodeFormat.QR_CODE.equals(format)) ||
            (isBarcodeTypeCode39 && BarcodeFormat.CODE_39.equals(format)) ||
            (isBarcodeTypeEAN13 && BarcodeFormat.CODE_39.equals(format)) ||
            (isBarcodeTypeEAN8 && BarcodeFormat.EAN_13.equals(format)) ||
            (isBarcodeTypeUPCE && BarcodeFormat.UPC_E.equals(format)) ||
            (isBarcodeTypeCode93 && BarcodeFormat.CODE_93.equals(format)) ||
            (isBarcodeTypeCode128 &&  BarcodeFormat.CODE_128.equals(format))) {
            return true;
        }
        return false;
    }
}