import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum UserType { broadcaster, watcher }
var configuration = <String, dynamic>{
  'iceServers': [
    // {'url': 'stun:stun01.sipphone.com'},
    // {'url': 'stun:stun.ekiga.net'},
    // {'url': 'stun:stun.fwdnet.net'},
    // {'url': 'stun:stun.ideasip.com'},
    // {'url': 'stun:stun.iptel.org'},
    // {'url': 'stun:stun.rixtelecom.se'},
    // {'url': 'stun:stun.schlund.de'},
    {'url': 'stun:stun.l.google.com:19302'},
    {'url': 'stun:stun1.l.google.com:19302'},
    {'url': 'stun:stun2.l.google.com:19302'},
    {'url': 'stun:stun3.l.google.com:19302'},
    {'url': 'stun:stun4.l.google.com:19302'},
    // {'url': 'stun:stunserver.org'},
    // {'url': 'stun:stun.softjoys.com'},
    // {'url': 'stun:stun.voiparound.com'},
    // {'url': 'stun:stun.voipbuster.com'},
    // {'url': 'stun:stun.voipstunt.com'},
    // {'url': 'stun:stun.voxgratia.org'},
    // {'url': 'stun:stun.xten.com'},
    // {'url': 'stun:stun.stunprotocol.org:3478'},
    // {
    //   'url': 'turn:numb.viagenie.ca',
    //   'credential': 'muazkh',
    //   'username': 'webrtc@live.com'
    // },
    // {
    //   'url': 'turn:192.158.29.39:3478?transport=udp',
    //   'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
    //   'username': '28224511:1379330808'
    // },
    // {
    //   'url': 'turn:192.158.29.39:3478?transport=tcp',
    //   'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
    //   'username': '28224511:1379330808'
    // },
    {
      'url': dotenv.env['RTC_TURN_SERVER'],
      'credential': dotenv.env['RTC_TURN_CREDENTIAL'],
      'username': dotenv.env['RTC_TURN_USER'],
    },
  ]
};

final offerSdpConstraints = <String, dynamic>{
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

final loopbackConstraints = <String, dynamic>{
  'mandatory': {},
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ],
};

/* *******************************************************
 *  flutter_webrtc 를 이용해  1:1 데이터 채널 구현
 *  텍스트 전송 및 파일 전송 가능.
 *  시그널 서버는 socket io 3 버전을 기준으로 서버(node js) 및 클라이언트 구현
 *  (https://socket.io/blog/socket-io-3-release/)
 *  @author : hodong.kim
 * *******************************************************/
class DataChannelController {
  void Function(RTCDataChannel)? onDataChannelConnected;
  void Function(RTCDataChannelMessage)? onMessage;
  void Function(String)? onLog;
  void Function(IO.Socket, String)? onTimeout;
  String? _room;
  UserType? _userType;

  String? _url = dotenv.env['RTC_SIGNAL_SERVER'];
  // String _url = 'ws://192.168.0.20:3337';  ;
  IO.Socket? socket;
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _rtcDataChannel;
  bool? isChannelConnected = false;
  bool? _isConnectFail = false;
  List<RTCIceCandidate>? _tempCandidate = [];

  Timer? _connectTimer;

  DataChannelController(
      UserType userType,
      String room,
      ) {
    _room = room;
    _userType = userType;

    socket = IO.io(
        _url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());

    /*
    final socketPath = dotenv.env['RTC_SIGNAL_PATH'];
    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNewConnection();

    if (socketPath != null && socketPath.isNotEmpty) {
      options.setPath(socketPath);
    }

    socket = IO.io(_url, options.build());
     */

    _startSocketEvent();
    // RTCDataChannelMessage.fromBinary()
  }

  _onDataChannel(RTCDataChannel dataChannel) {
    dataChannel.onMessage = (message) {
      // message.isBinary
      // if (onLog != null) onLog('message log ${message.text}');
      if (onMessage != null) onMessage!(message);
    };

    if (_userType == UserType.broadcaster) {
      dataChannel.onDataChannelState = (state) {
        if (onLog != null) onLog!(state.toString());
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          isChannelConnected = true;
          if (onDataChannelConnected != null)
            onDataChannelConnected!(dataChannel);
        }
      };
    } else {
      _rtcDataChannel = dataChannel;

      isChannelConnected = true;
      if (onDataChannelConnected != null) onDataChannelConnected!(dataChannel);
    }
  }

  _startSocketEvent() {
    socket!.onConnect((_) {
      if (onLog != null) onLog!('onconnect');
      socket!.emit(_userType.toString().split('.').last, _room);
    });
    socket!.onConnectError((_) {
      if (onLog != null) onLog!('onconnect-error');
    });
    socket!.onDisconnect((_) {
      if (onLog != null) onLog!('ondisconnect');
    });
    socket!.on('candidate', (data) {
      // 'candidate': candidate,
      // 'sdpMid': sdpMid,
      // 'sdpMLineIndex': sdpMlineIndex
      if (onLog != null)
        onLog!( "candidate --> ${data['candidate']}, ${data['sdpMid']}, ${data['sdpMLineIndex']}");
      _tempCandidate!.add(RTCIceCandidate(
          data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
      if (_peerConnection != null) {
        _tempCandidate!.forEach((element) {
          _peerConnection!.addCandidate(element);
        });
        _tempCandidate!.clear();
      }
    });

    // socket.on('data-allready', (data) {
    //   if (onLog != null)
    //     onLog('data-allready receive: ${_userType.toString()}');
    // });

    socket!.on('fail', (_) {
      if (!_isConnectFail!) {
        _isConnectFail = true;
        if (onTimeout != null) onTimeout!(socket!, _room!);
      }
    });

    if (_userType == UserType.broadcaster) {
      socket!.on('watcher', _createPeerConnect);
      socket!.on('answer', (data) {
        _peerConnection!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));
        // watcher로 부터 응답이 온 후
        _connectTimer = Timer(Duration(seconds: 4), () {
          _isConnectFail = true;
          socket!.emit('fail', _room);
          if (onTimeout != null) onTimeout!(socket!, _room!);
        });
      });
    } else {
      socket!.on('broadcaster', (_) {
        socket!.emit('watcher', _room);
      });
      socket!.on('offer', _createPeerConnect);
    }
  }

  _createPeerConnect(data) async {
    if (_peerConnection != null) return;

    try {
      // configuration = {};
      _peerConnection =
      await createPeerConnection(configuration, loopbackConstraints);
      if (_userType == UserType.watcher) {
        await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));
      }
      _peerConnection!.onSignalingState = (state) => {};
      _peerConnection!.onIceGatheringState = (state) => {};
      _peerConnection!.onIceConnectionState = (state) => {};
      _peerConnection!.onIceCandidate = (candidate) {
        socket!.emit('candidate', {'room': _room, 'data': candidate.toMap()});
      };
      _peerConnection!.onRenegotiationNeeded = () => {};

      _peerConnection!.onConnectionState = (state) {
        if (onLog != null) onLog!('onConnectionState: ${state.toString()}');

        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          print('connected.. fail time cancel !!!');
          if (_connectTimer != null) _connectTimer!.cancel();
        }

        // if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        //   if (!_isConnectFail) {
        //     _isConnectFail = true;
        //     socket.emit('fail', _room);
        //     if (onTimeout != null) onTimeout(socket, _room);
        //   }
        // }
      };

      RTCSessionDescription description;
      String emitType = '';
      if (_userType == UserType.broadcaster) {
        emitType = 'offer';
        await createDataChannel();
        description = await _peerConnection!.createOffer(offerSdpConstraints);
      } else {
        emitType = 'answer';
        _peerConnection!.onDataChannel = _onDataChannel;
        description = await _peerConnection!.createAnswer(offerSdpConstraints);
      }

      await _peerConnection!.setLocalDescription(description);
      var localDescription = await _peerConnection!.getLocalDescription();
      socket!.emit(emitType, {
        'room': _room,
        'data': {'sdp': localDescription!.sdp, 'type': localDescription.type}
      });
    } catch (e) {
      if (onLog != null) onLog!('createPeerConnect error : ${e.toString()}');
    }

    if (onLog != null)
      onLog!('init _peerConnection state : ${_peerConnection!.connectionState.toString()}');
  }

  createDataChannel() async {
    var channelOtp = RTCDataChannelInit();
    channelOtp.id = 1;
    channelOtp.ordered = true;
    channelOtp.maxRetransmitTime = -1;
    channelOtp.maxRetransmits = -1;
    channelOtp.protocol = 'sctp';
    channelOtp.negotiated = false;

    _rtcDataChannel =
    await _peerConnection!.createDataChannel('dataChannel', channelOtp);
    _onDataChannel(_rtcDataChannel!);
  }

  bool sendMessage(dynamic message) {
    if (isChannelConnected!) {
      if (message is String) {
        print('send message  String');
        _rtcDataChannel!.send(RTCDataChannelMessage(message));
      } else {
        print('send message  binary');
        _rtcDataChannel!.send(RTCDataChannelMessage.fromBinary(message));
      }
    } else {
      if (onLog != null) onLog!('no channel connect');
    }
    return isChannelConnected!;
  }

  void stopRtc() async {
    onDataChannelConnected = null;
    onMessage = null;
    onTimeout = null;
    onLog = null;

    if (_rtcDataChannel != null) await _rtcDataChannel!.close();
    if (_peerConnection != null) await _peerConnection!.close();
    if (_connectTimer != null) _connectTimer!.cancel();
  }

  Future<void> dispose() async {
    try {
      if (socket != null) socket!.dispose();
      if (_rtcDataChannel != null) await _rtcDataChannel!.close();
      if (_peerConnection != null) await _peerConnection!.close();
      if (_connectTimer != null) _connectTimer!.cancel();
      // socket = null;
      //
      // _rtcDataChannel = null;
      // _peerConnection = null;
      _isConnectFail = false;
      isChannelConnected = false;
    } catch (e) {
      print(e.toString());
    }
  }
}
