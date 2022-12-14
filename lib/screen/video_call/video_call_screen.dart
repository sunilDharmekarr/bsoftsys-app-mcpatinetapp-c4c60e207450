import 'dart:async';
import 'dart:convert';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/chatUrlModel.dart';
import 'package:mumbaiclinic/screen/webChat/webChat.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:pip_view/pip_view.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/model/video_call_token_model.dart';
import 'package:mumbaiclinic/screen/home/home_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class VideoCallScreen extends StatefulWidget {
  static const routeName = '/video';

  /// non-modifiable channel name of the page
  final String appointmentId;

  /// non-modifiable client role of the page
  // final ClientRole role;

  /// Creates a call page with given channel name.
  const VideoCallScreen({Key key, this.appointmentId}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  double xPosition = 0;
  double yPosition = 0;

  var APP_ID = "e433f861ebd04dbc85569e529f3cfd0d";
  String Token;
  String appointmentid;
  ClientRole _role = ClientRole.Broadcaster;
  int viewType = 0;
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  RtcEngine _engine;
  int uid = 0;
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    //Disable screen on
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Enable screen on
    Wakelock.enable();
    appointmentid = widget.appointmentId;
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    try {
      String userId = PreferenceManager.getUserId();
      uid = int.parse(userId);
    } catch (e) {}
    await _initAgoraRtcEngine();

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    //getVideoCallToken();

    print("The appointment in get is : $appointmentid");
    Loader.showProgress();
    await MumbaiClinicNetworkCall.getRequest(
        endPoint: APIConfig.getVideoCallToken(appointmentid),
        context: context,
        header: Utils.getHeaders(),
        onSuccess: (response) {
          ResponseModel responseModel =
              ResponseModel.fromJson(json.decode(response));
          if (responseModel.success == 'true') {
            VideoCallTokenModel videoCallTokenModel =
                VideoCallTokenModel.fromJson(json.decode(response));
            setState(() {
              Token = videoCallTokenModel.payload.key.toString();
              print("The api token is : $Token");
              Loader.hide();
            });
          } else {
            Loader.hide();
            Utils.showToast(message: responseModel.error, isError: true);
            //Navigator.pop(context);
          }
        },
        onError: (error) {
          Loader.hide();
          Utils.showToast(message: error);
          //Navigator.pop(context);
        });
    Loader.hide();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(height: 640, width: 480);
    configuration.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    await _engine.setCameraZoomFactor(1.0);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, appointmentid, null, uid);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(_role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        print("Agora: error $code");
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        print("Agora: joinChannelSuccess $uid");
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        print("Agora: leaveChannel $stats");
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        print("Agora: userJoined $uid");
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        print("Agora: userOffline $uid");
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
          print("Agora: userOffline length ${_users.length}");
          if (_users == null ||
              _users.length == 0 ||
              (_users.length == 1 && _users[0] == this.uid)) {
            _onCallEnd(context);
          }
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
    ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (_role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(
          uid: uid,
          channelId: appointmentid,
        )));
    return list;
  }

  // Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  // Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();

    return Row(children: wrappedViews);
    // return Expanded(child: Row(children: wrappedViews));
  }

  // Video layout wrapper
  Widget _viewRows(_width, _height) {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(children: <Widget>[_videoView(views[0])]));

      case 2:
        return Container(
          child: Stack(
            children: <Widget>[
              // _expandedVideoRow([views[0]]),
              _expandedVideoRow([views[1]]),
              Positioned(
                top: yPosition,
                left: xPosition,
                child: GestureDetector(
                  onPanUpdate: (tapInfo) {
                    setState(() {
                      xPosition += tapInfo.delta.dx;
                      yPosition += tapInfo.delta.dy;
                    });
                  },
                  child: Container(
                    width: _width * 0.35,
                    height: _height * 0.20,
                    child: Material(
                      elevation: 4,
                      type: MaterialType.card,
                      clipBehavior: Clip.antiAlias,
                      child: _expandedVideoRow([views[0]]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 3:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 3))
            ],
          ),
        );

      case 4:
        return Container(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4))
            ],
          ),
        );

      default:
    }

    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (_role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    //Disable screen on
    Wakelock.disable();
    // Navigator.pop(context);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void getVideoCallToken() async {}

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    // final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    // appointmentid = args.appointment_id;
    return WillPopScope(
      onWillPop: () async => _role == ClientRole.Audience,
      child: PIPView(
        builder: (context, isFloating) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 10.0,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    PIPView.of(context).presentBelow(HomeScreen());
                  },
                  icon: Icon(Icons.picture_in_picture_alt,
                      size: 30.0, color: ColorTheme.darkGreen),
                ),
                IconButton(
                  onPressed: () async {
                    String _url;
                    var body = {
                      "appointment_id": appointmentid,
                    };
                    await MumbaiClinicNetworkCall.postRequest(
                        endPoint: APIConfig.getChatURL,
                        header: Utils.getHeaders(),
                        body: body,
                        onSuccess: (response) {
                          if (response != null) {
                            ResponseModel responseModel =
                                ResponseModel.fromJson(json.decode(response));
                            if (responseModel.success == 'true') {
                              ChatUrlModel chatUrlModel =
                                  ChatUrlModel.fromJson(json.decode(response));
                              _url = chatUrlModel.payload[0].chatUrl;
                              // Navigator.push(context, CupertinoPageRoute(builder: (_) => WebChat(
                              //   'Chat',
                              //   _url
                              // )));
                              PIPView.of(context).presentBelow(WebChat(
                                'Chat',
                                _url,
                                appointmentid,
                                isVideo: true,
                              ));
                            } else {
                              Utils.showToast(
                                  message:
                                      'Failed to load chat: ${responseModel.error}',
                                  isError: true);
                            }
                          } else {
                            Utils.showToast(
                                message: 'Failed to load chat', isError: true);
                          }
                        },
                        onError: (error) {
                          Utils.showToast(
                              message: 'Failed to load chat: $error',
                              isError: true);
                        });
                  },
                  icon: Image.asset(
                    AppAssets.chat,
                    width: 30,
                    height: 30,
                    color: ColorTheme.iconColor,
                  ),
                ),
                AppText.getBoldText('Video Call', 15.0, ColorTheme.darkGreen),
              ],
            ),
          ),
          body: Center(
              child: Stack(
                  children: <Widget>[_viewRows(_width, _height), _toolbar()])),
        ),
      ),
    );
  }
}
