#import "QuietModemKit.h"
#import <XCTest/XCTest.h>

@interface QuietModemKitTests : XCTestCase
@end

@implementation QuietModemKitTests

- (void)testFrameLoopback {
  QMTransmitterConfig *txConf =
      [[QMTransmitterConfig alloc] initWithKey:@"ultrasonic-fsk"];
  QMReceiverConfig *rxConf =
      [[QMReceiverConfig alloc] initWithKey:@"ultrasonic-fsk"];

  QMFrameTransmitter *tx =
      [[QMFrameTransmitter alloc] initLoopbackWithConfig:txConf];
  QMFrameReceiver *rx = [[QMFrameReceiver alloc] initLoopbackWithConfig:rxConf];

  [rx setBlocking:5 withNano:0];

  NSData *payload = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

  [tx send:payload];

  NSData *recvd = [rx receive];

  XCTAssertTrue([recvd isEqualToData:payload]);

  [tx close];
  [rx close];

  tx = nil;
  rx = nil;
}

- (void)testFrameLoopbackCallback {
  QMTransmitterConfig *txConf =
      [[QMTransmitterConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMReceiverConfig *rxConf =
      [[QMReceiverConfig alloc] initWithKey:@"audible-7k-channel-0"];

  QMFrameTransmitter *tx =
      [[QMFrameTransmitter alloc] initLoopbackWithConfig:txConf];
  QMFrameReceiver *rx = [[QMFrameReceiver alloc] initLoopbackWithConfig:rxConf];

  NSCondition *cond = [[NSCondition alloc] init];
  NSData __block *recvd;
  dispatch_queue_t queue =
      dispatch_queue_create("test queue", DISPATCH_QUEUE_SERIAL);

  [rx setReceiveCallback:^(NSData *frame) {
    recvd = frame;
    [cond lock];
    [cond signal];
    [cond unlock];
  }
                 onQueue:queue];

  NSData *payload = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

  [tx send:payload];

  [cond lock];
  [cond waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
  [cond unlock];

  XCTAssertTrue([recvd isEqualToData:payload]);

  [tx close];
  [rx close];

  tx = nil;
  rx = nil;
}

- (void)testLwipLoopbackUdp {
  QMTransmitterConfig *txConf =
      [[QMTransmitterConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMReceiverConfig *rxConf =
      [[QMReceiverConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMNetworkInterfaceConfig *conf =
      [[QMNetworkInterfaceConfig alloc] initWithTransmitterConfig:txConf
                                               withReceiverConfig:rxConf];
  conf.localInetAddress = @"192.168.0.3";
  conf.localNetmask = @"255.255.255.0";
  conf.localGateway = @"192.168.0.1";
  QMNetworkInterface *intf =
      [[QMNetworkInterface alloc] initLoopbackWithConfig:conf];

  QMSocketAddress *addrA =
      [QMSocketAddress withIpAddress:@"192.168.0.3" withPort:3000];
  QMUdpSocket *socketA = [QMUdpSocket udpSocketWithAddress:addrA];

  QMSocketAddress *addrB =
      [QMSocketAddress withIpAddress:@"192.168.0.3" withPort:3001];
  QMUdpSocket *socketB = [QMUdpSocket udpSocketWithAddress:addrB];

  NSData *payload = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

  int sent = [socketA sendData:payload toAddress:addrB];

  XCTAssertEqual(sent, [payload length]);

  QMSocketAddress *sender;
  NSMutableData *recvBuf = [NSMutableData dataWithLength:1500];
  int recvd = [socketB recvData:recvBuf fromAddress:&sender];
  NSData *recvSlice = [recvBuf subdataWithRange:NSMakeRange(0, recvd)];

  XCTAssertEqual(recvd, [payload length]);
  XCTAssertTrue([recvSlice isEqualToData:payload]);
  XCTAssertTrue([addrA isEqual:sender]);

  [intf close];
  intf = nil;
}

- (void)testLwipLoopbackAutoIP {
  QMTransmitterConfig *txConf =
      [[QMTransmitterConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMReceiverConfig *rxConf =
      [[QMReceiverConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMNetworkInterfaceConfig *conf =
      [[QMNetworkInterfaceConfig alloc] initWithTransmitterConfig:txConf
                                               withReceiverConfig:rxConf];

  QMNetworkInterface *intf =
      [[QMNetworkInterface alloc] initLoopbackWithConfig:conf];

  [NSThread sleepForTimeInterval:10.0];

  QMSocketAddress *addrA =
      [QMSocketAddress withIpAddress:@"0.0.0.0" withPort:3333];
  QMUdpSocket *socketA = [QMUdpSocket udpSocketWithAddress:addrA];

  XCTAssertTrue([socketA setBroadcast:YES]);

  QMSocketAddress *addrB =
      [QMSocketAddress withIpAddress:@"0.0.0.0" withPort:3334];
  QMUdpSocket *socketB = [QMUdpSocket udpSocketWithAddress:addrB];

  NSData *payload = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
  QMSocketAddress *dest =
      [QMSocketAddress withIpAddress:@"169.254.255.255" withPort:3334];

  int sent = [socketA sendData:payload toAddress:dest];

  XCTAssertEqual(sent, [payload length]);

  [socketA sendData:payload
          toAddress:[QMSocketAddress withIpAddress:@"1.2.3.4"]];

  QMSocketAddress *sender;
  NSMutableData *recvBuf = [NSMutableData dataWithLength:1500];
  int recvd = [socketB recvData:recvBuf fromAddress:&sender];
  NSData *recvSlice = [recvBuf subdataWithRange:NSMakeRange(0, recvd)];

  XCTAssertEqual(recvd, [payload length]);
  XCTAssertTrue([recvSlice isEqualToData:payload]);
  XCTAssertTrue([[intf getLocalAddress] isEqual:[sender addr]]);

  [intf close];
  intf = nil;

  [NSThread sleepForTimeInterval:1.0];
}

- (void)testLwipLoopbackTcp {
  QMTransmitterConfig *txConf =
      [[QMTransmitterConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMReceiverConfig *rxConf =
      [[QMReceiverConfig alloc] initWithKey:@"audible-7k-channel-0"];
  QMNetworkInterfaceConfig *conf =
      [[QMNetworkInterfaceConfig alloc] initWithTransmitterConfig:txConf
                                               withReceiverConfig:rxConf];
  conf.localInetAddress = @"192.168.0.9";
  conf.localNetmask = @"255.255.255.0";
  conf.localGateway = @"192.168.0.1";
  QMNetworkInterface *intf =
      [[QMNetworkInterface alloc] initLoopbackWithConfig:conf];

  QMSocketAddress *addrA =
      [QMSocketAddress withIpAddress:@"192.168.0.9" withPort:3000];
  QMTcpSocket *server = [QMTcpSocket tcpSocketWithAddress:addrA];
  XCTAssertTrue([server listen]);

  QMSocketAddress *addrB = [QMSocketAddress withIpAddress:@"192.168.0.9"];
  QMTcpSocket *client = [QMTcpSocket tcpSocketWithAddress:addrB];
  QMSocketAddress *clientAddress = [client getLocalAddress];

  NSData *payload = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

  NSThread *serverThread = [[NSThread alloc] initWithBlock:^{
    QMTcpSocket *peer = [server accept];
    QMSocketAddress *peerAddress = [peer getRemoteAddress];

    XCTAssertTrue([peerAddress isEqual:clientAddress]);

    NSMutableData *recvBuf = [NSMutableData dataWithLength:[payload length]];
    int recvd = [peer recvData:recvBuf];
    NSData *recvSlice = [recvBuf subdataWithRange:NSMakeRange(0, recvd)];

    XCTAssertEqual(recvd, [payload length]);
    XCTAssertTrue([recvSlice isEqual:payload]);
  }];
  [serverThread start];

  XCTAssertTrue([client setReceiveTimeout:2.0]);
  XCTAssertTrue([client setReceiveBufferSize:4096]);
  BOOL connected = [client connect:addrA];
  XCTAssertTrue(connected);

  int sent = [client sendData:payload];
  XCTAssertEqual(sent, [payload length]);

  while (![serverThread isFinished]) {
    [NSThread sleepForTimeInterval:0.1];
  }

  [intf close];
  intf = nil;
  [NSThread sleepForTimeInterval:0.5];
}

@end
