QuietModemKit
==============

This is the iOS framework for https://github.com/quiet/quiet

With this library, you can send data through sound.

Other platforms:
* Javascript: https://github.com/quiet/quiet-js
* Android: https://github.com/quiet/org.quietmodem.Quiet

Building
--------------
It is recommended that you use Carthage to build QuietModemKit. Simply add `github "Quiet/QuietModemKit"` to your Cartfile and run `carthage update`.

Example
--------------
Transmitter:
```
#import <QuietModemKit/QuietModemKit.h>

int main(int argc, char * argv[]) {
    QMTransmitterConfig *txConf = [[QMTransmitterConfig alloc] initWithKey:@"ultrasonic-experimental"];

    QMFrameTransmitter *tx = [[QMFrameTransmitter alloc] initWithConfig:txConf];

    NSString *frame_str = @"asdfsd";
    NSData *frame = [frame_str dataUsingEncoding:NSUTF8StringEncoding];
    [tx send:frame];

    CFRunLoopRun();
    return 0;
}

```

Receiver:
```
#import <QuietModemKit/QuietModemKit.h>

void (^request_callback)(BOOL) = ^(BOOL granted){
    QMReceiverConfig *rxConf = [[QMReceiverConfig alloc] initWithKey:@"ultrasonic-experimental"];

    QMFrameReceiver *rx = [[QMFrameReceiver alloc] initWithConfig:rxConf];

    sleep(8);
    NSData *rcv = [rx receive];
    printf("%s\n", [rcv bytes]);
};

int main(int argc, char * argv[]) {
    [[AVAudioSession sharedInstance] requestRecordPermission:request_callback];

    CFRunLoopRun();
    return 0;
}
```

Note that we ask for the Record permission. This is required to use the receiver.

License
--------------
3-Claused BSD, plus third-party licenses (mix of MIT and BSD, see licenses/)
