//
//  PGMyPlugin.h
//  QRPlugin01
//
//  Created by Tome on 2014/07/08.
//
//

#import <Cordova/CDV.h>
#import "QRViewController3.h"

@interface PGMyBarcodeReader : CDVPlugin<CloseDelegate> {
    NSString *callbackId;
    QRViewController3 *view;
}
-(void)openQRReader:(CDVInvokedUrlCommand*)command;
-(void)closeView:(NSString*)str;

@end
