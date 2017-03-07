QuietModemKit
==============

This is the iOS framework for https://github.com/quiet/quiet

With this library, you can send data through sound.

Live demo: https://quiet.github.io/quiet-js/

Other platforms:
* Javascript: https://github.com/quiet/quiet-js
* Android: https://github.com/quiet/org.quietmodem.Quiet

Building
--------------
It is recommended that you use Carthage to build QuietModemKit. Simply add `github "Quiet/QuietModemKit"` to your Cartfile and run `carthage update`.

Example
--------------
Transmitter:
```objc
#import <QuietModemKit/QuietModemKit.h>

int main(int argc, char * argv[]) {
    QMTransmitterConfig *txConf = [[QMTransmitterConfig alloc] initWithKey:@"ultrasonic-experimental"];

    QMFrameTransmitter *tx = [[QMFrameTransmitter alloc] initWithConfig:txConf];

    NSString *frame_str = @"Hello, World!";
    NSData *frame = [frame_str dataUsingEncoding:NSUTF8StringEncoding];
    [tx send:frame];

    CFRunLoopRun();

    [tx close];

    return 0;
}

```

Receiver:
```objc
#import <QuietModemKit/QuietModemKit.h>

static QMFrameReceiver *rx;

void (^recv_callback)(NSData*) = ^(NSData *frame){
    printf("%s\n", [frame bytes]);
};

void (^request_callback)(BOOL) = ^(BOOL granted){
    QMReceiverConfig *rxConf = [[QMReceiverConfig alloc] initWithKey:@"ultrasonic-experimental"];
    rx = [[QMFrameReceiver alloc] initWithConfig:rxConf];
    [rx setReceiveCallback:recv_callback];
};

int main(int argc, char * argv[]) {
    [[AVAudioSession sharedInstance] requestRecordPermission:request_callback];

    CFRunLoopRun();

    if (rx != nil) {
        [rx close];
    }

    return 0;
}
```

Note that we ask for the Record permission. This is required to use the receiver.

Profiles
--------------
The modem can be used audibly or via ultrasonic sound. `QMTransmitterConfig` and `QMReceiverConfig` are used to select modem configuration. For a full list of valid keys, refer to the top-level keys of [quiet-profiles.json](https://github.com/quiet/QuietModemKit/blob/master/quiet-profiles.json).

License
--------------
3-Claused BSD, plus third-party licenses (mix of MIT and BSD, see licenses/)
