//
//  PGMyPlugin.m
//  QRPlugin01
//
//  Created by ITS-J on 2014/07/08.
//  cordova >= 3.6
//
//

#import <AVFoundation/AVFoundation.h>
#import "PGMyBarcodeReader.h"
#import "QRViewController3.h"
@implementation PGMyBarcodeReader

/*  openQRReader arguments:
 * INDEX   ARGUMENT
 *  0       camera position(１：背面カメラ／２：前面カメラ)
 *  1       typeQRCode
 *  2       typeCode39
 *  3       typeCode39Mod43
 *  4       typeEAN13
 *  5       typeEAN8
 *  6       typeUPCE
 *  7       typeCode93
 *  8       typeCode128
 */
- (void)openQRReader:(CDVInvokedUrlCommand *)command {
    callbackId = command.callbackId;
    view = [[QRViewController3 alloc] init];
    BOOL err = false;
    @try {
        NSArray* arguments = command.arguments;
        // カメラの向き
        NSNumber *cameraValue = arguments.count > 0 ? [arguments objectAtIndex:0] : nil;
        AVCaptureDevicePosition camera = cameraValue ?
        [cameraValue intValue] : AVCaptureDevicePositionBack;
        
        view.devicePosition  = camera;
        view.typeQRCode      = arguments.count > 1 ? [[arguments objectAtIndex:1] boolValue] : false;
        view.typeCode39      = arguments.count > 2 ? [[arguments objectAtIndex:2] boolValue] : false;
        view.typeCode39Mod43 = arguments.count > 3 ? [[arguments objectAtIndex:3] boolValue] : false;
        view.typeEAN13       = arguments.count > 4 ? [[arguments objectAtIndex:4] boolValue] : false;
        view.typeEAN8        = arguments.count > 5 ? [[arguments objectAtIndex:5] boolValue] : false;
        view.typeUPCE        = arguments.count > 6 ? [[arguments objectAtIndex:6] boolValue] : false;
        view.typeCode93      = arguments.count > 7 ? [[arguments objectAtIndex:7] boolValue] : false;
        view.typeCode128     = arguments.count > 8 ? [[arguments objectAtIndex:8] boolValue] : false;
        if (!view.typeQRCode &&
            !view.typeCode39 &&
            !view.typeCode39Mod43 &&
            !view.typeEAN13 &&
            !view.typeEAN8 &&
            !view.typeUPCE &&
            !view.typeCode93 &&
            !view.typeCode128) {
            view.typeQRCode = true;
        }
        view.delegate = self;
        [super.viewController presentViewController:view animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"例外名：%@", exception.name);
        NSLog(@"例外内容：%@", exception.reason);
        err = true;
    }
    @finally {
        if (!view.viewControllerStart || err) {
            // 画面を正常終了させるために、画面表示中の場合クローズ処理をタイマー起動
            if (view.isBeingPresented) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @1, @"status",
                                          @"読み取り画面の表示でエラーが発生しました。", @"msg", nil];

                [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(closeViewTimer:)
                                               userInfo:userInfo
                                                repeats:NO
                 ];
            } else {
                [self closeView : @1 : @"読み取り画面の表示でエラーが発生しました。"];
            }
                
        }
    }
}

#pragma mark -delegate
- (void) closeView : (NSString *) str {
    // 画面を正常終了させるために、画面表示中の場合クローズ処理をタイマー起動
    if (view.isBeingPresented || str) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @0, @"status",
                                  str, @"msg", nil];
    
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(closeViewTimer:)
                                       userInfo:userInfo
                                        repeats:NO
        ];
    } else {
        [self closeView : @0 : str];
    }
}

/*
 * クローズ処理
 * タイマーでクローズ処理を実施する。
 * @param timer
 */
-(void) closeViewTimer:(NSTimer *)timer {
    // 画面起動中にクローズ処理が呼ばれると、画面が固まるため、タイマー起動する
    NSNumber *status = [(NSDictionary *)timer.userInfo objectForKey:@"status"];
    NSString *msg = [(NSDictionary *)timer.userInfo objectForKey:@"msg"];
    
    [self closeView : status : msg];
}

/*
 * クローズ処理
 * コード読み取り画面を閉じ、メッセージを返す。
 * @param status 0:OK 1:NG
 * @param msg
 */
-(void) closeView:(NSNumber *)status : (NSString *) msg {
    // 画面を閉じる
    [view dismissViewControllerAnimated:YES completion:nil];
    
    // メッセージを返す(正常終了：コード／キャンセル：未設定／エラー：エラーメッセージ)
    CDVPluginResult *result = nil;
    if ([status isEqualToNumber:@0]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    // [self writeJavascript:ret];
    //[self.commandDelegate evalJs:ret];

    // 初期化
    view.delegate = nil;
    view = nil;
    callbackId = nil;
}
@end
