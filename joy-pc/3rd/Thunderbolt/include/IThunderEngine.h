// ThunderEngine.h

#pragma once
#ifndef THUNDER_ENGINE_H
#define THUNDER_ENGINE_H

#define YYLIVE_API_EXPORTS
#define THUNDER_ENGINE_EXPORTS

#ifdef THUNDER_ENGINE_EXPORTS
#define THUNDER_ENGINE __declspec(dllexport)
#else
#define THUNDER_ENGINE __declspec(dllimport)
#endif
/************************************************************************/
/* Description of Terms: 
1. Initialization: Indicates that the initialize function is called and Succeeded is returned.
2. Joining room: Indicates that the joinRoom function is called and Succeeded is returned.
3. Joining room successfully: Indicates that the onJoinRoomSuccess callback notification is returned.
/************************************************************************/
namespace Thunder
{
#define MAX_DEVICE_NAME_LEN 512 // Device name
#define MAX_DEVICE_DESC_LEN 512 // Device description
#define MAX_DEVICE_COUNT 16 // Maximum quantity of devices
#define MAX_THUNDER_URL_LEN 512 // url length
#define MAX_THUNDER_UID_LEN 65 // uid length
#define MAX_THUNDER_ROOMID_LEN 65 // roomId length
#define MAX_THUNDER_TASKID_LEN 20 // taskId length
#define MAX_THUNDER_TRANSCODINGUSER_COUNT 9 // Number of users with maximum image transcoding

#define MAX_THUNDER_VIDEO_BUFFER_PLANE 8 // Maximum plane number of video frames (I420: 3, RGB: 1)
#define MAX_THUNDER_MIX_AUDIO_COUNT 16  // Maximum value in list of information about mixed audio stream
#define MAX_THUNDER_MIX_VIDEO_COUNT 16  // Maxium value in list of information about mixed video streams

enum AREA_TYPE
{
  AREA_DEFAULT = 0, // Default (domestic)
  AREA_FOREIGN = 1, // Overseas
  AREA_RESERVED = 2, // reserved
};

enum THUNDER_PROFILE
{
  PROFILE_DEFAULT = 0, // Default mode (1)
  PROFILE_NORMAL = 1, // Audio/video mode
  PROFILE_ONLY_AUDIO = 2, // Audio-only mode, applicable to audio-only optimization
};

enum ROOM_CONFIG_TYPE
{
  ROOM_CONFIG_LIVE = 0, // Live streaming
  ROOM_CONFIG_COMMUNICATION = 1, // Communication
  ROOM_CONFIG_GAME = 3, // Game
  ROOM_CONFIG_MultiAudioRoom = 4, // Multi-person voice chat room
  ROOM_CONFIG_Conference = 5, // Conference
};

enum COMMUT_MODE
{
  COMMUT_MODE_DEFAULT = 0, // =1 by default
  COMMUT_MODE_HIGH = 1, // High interactive mode
  COMMUT_MODE_LOW = 2, // Low interactive mode
};

enum SCENARIO_MODE
{
  SCENARIO_MODE_DEFAULT = 0, // =1 by default
  SCENARIO_MODE_STABLE_FIRST, // Fluent priority: applicable for stable education
  SCENARIO_MODE_QUALITY_FIRST, // Tone quality priority: applicable for show field with a few or without interaction
};

enum AUDIO_PROFILE_TYPE
{
  AUDIO_PROFILE_DEFAULT = 0, // Default settings NET_AAC_ELD = 38，指定44.1 KHz采样率，双声道，编码码率约 40 kbps
  AUDIO_PROFILE_SPEECH_STANDARD = 1, // NET_SILK_16K  = 2
  AUDIO_PROFILE_MUSIC_STANDARD_STEREO = 2, // NET_AACPLUS = 1
  AUDIO_PROFILE_MUSIC_STANDARD = 3, // NET_AAC_48K_MONO = 42
  AUDIO_PROFILE_MUSIC_HIGH_QUALITY_STEREO = 4, // NET_AAC_128K = 35
};

enum ThunderSourceType
{
  THUNDER_AUDIO_MIC = 0, // Only microphone
  THUNDER_AUDIO_FILE = 1, // Only file
  THUNDER_AUDIO_MIX = 2, // Microphone and file
  THUNDER_AUDIO_TYPE_NONE = 10, // Stop all uplink audio data
};

/**
@brief 日志过滤器
*/
enum LOG_FILTER
{
  LOG_LEVEL_TRACE = 0,
  LOG_LEVEL_DEBUG = 1,
  LOG_LEVEL_INFO = 2,
  LOG_LEVEL_WARN = 3,
  LOG_LEVEL_ERROR = 4,
  LOG_LEVEL_RELEASE = 10,
};

/**
@brief 音频录制-文件格式
*/
enum AUDIO_RECORDING_QUALITY_TYPE
{
  AUDIO_RECORDING_QUALITY_LOW = 0, // Low tone quality
  AUDIO_RECORDING_QUALITY_MEDIUM = 1, // Mediocre tone quality
  AUDIO_RECORDING_QUALITY_HIGH = 2, // High tone quality
};

/**
 @brief 音频录制-录制质量
*/
enum AUDIO_RECORDING_FILE_TYPE
{
  AUDIO_RECORDING_WAV = 0,
  AUDIO_RECORDING_AAC = 1,
  AUDIO_RECORDING_MP3 = 2,
};

enum AUTH_RESULT
{
  AUTHRES_SUCCUSS = 0, // Authentication succeeded
  AUTHRES_ERR_SERVER_INTERNAL = 10000, // Internal server error, try again
  AUTHRES_ERR_NO_TOKEN = 10001, // token not carried. [ updateToken:] needs to be called.
  AUTHRES_ERR_TOKEN_ERR = 10002, // Token authentication failed (incorrect digital signature), which may be caused by incorrect appSecret
  AUTHRES_ERR_APPID = 10003, // appid in token is inconsistent with appid when authentication is executed
  AUTHRES_ERR_UID = 10004, // uid in token is inconsistent with uid when authentication is executed
  AUTHRES_ERR_TOKEN_EXPIRE = 10005, // token has expired
  AUTHRES_ERR_NO_APP = 10006, // App does not exist, which is not registered in the management background
  AUTHRES_ERR_TOKEN_WILL_EXPIRE = 10007, // token is about to expire, and users will be notified 30s in advance.
  AUTHRES_ERR_NO_BAND = 10008, // The user is baned
};

enum VideoRenderMode
{
  VIDEO_RENDER_MODE_FILL = 0, // Pull to full screen
  VIDEO_RENDER_MODE_ASPECT_FIT = 1, // Adapt to window
  VIDEO_RENDER_MODE_CLIP_TO_BOUNDS = 2, // Tailed to full screen
};

/**
@brief 开播玩法
*/
enum VideoPublishPlayType
{
  VIDEO_PUBLISH_PLAYTYPE_SINGLE = 0, // Single publishing
  VIDEO_PUBLISH_PLAYTYPE_INTERACT = 1, // Microphone-connection video publishing
  VIDEO_PUBLISH_PLAYTYPE_SCREENCAP = 2, // Screen recording publishing
};

/**
 @brief 开播档位
*/
enum VideoPublishMode
{
  VIDEO_PUBLISH_MODE_DEFAULT = -1, // Undefined. The broadcast definition is determined by configuration
  VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION = 1, // Fluent
  VIDEO_PUBLISH_MODE_NORMAL_DEFINITION = 2, // Standard definition
  VIDEO_PUBLISH_MODE_HIGH_DEFINITION = 3, // High definition
  VIDEO_PUBLISH_MODE_SUPER_DEFINITION = 4, // Ultra definition
  VIDEO_PUBLISH_MODE_BLUERAY = 5, // Blue light
};

enum USER_OFFLINE_REASON_TYPE
{
  USER_OFFLINE_QUIT = 1, // The user is offline actively
  USER_OFFLINE_DROPPED = 2, // The packet could not be received for long time, lost connection due to timeout. Note: Because SDK
                            // Unreliable channel is used, and the counterpart may leave our side actively. So it is misjudged as timeout offline
  USER_OFFLINE_BECOME_AUDIENCE = 3, // User status is switched from anchor to audience (live mode)
};

enum ThunderNetworkType
{
  THUNDER_NETWORK_TYPE_UNKNOWN = 0, // Unknown network connection type
  THUNDER_NETWORK_TYPE_DISCONNECTED = 1, // The network has been disconnected
  THUNDER_NETWORK_TYPE_CABLE = 2, // Cable network
  THUNDER_NETWORK_TYPE_WIFI = 3, // Wi-Fi (hotspot included)
  THUNDER_NETWORK_TYPE_MOBILE = 4, // Mobile network. 2G, 3G and 4G network cannot be differentiated
  THUNDER_NETWORK_TYPE_MOBILE_2G = 5, // 2G mobile network
  THUNDER_NETWORK_TYPE_MOBILE_3G = 6, // 3G mobile network
  THUNDER_NETWORK_TYPE_MOBILE_4G = 7, // 4G mobile network
};

enum ThunderAudioDeviceStatus
{
  THUNDER_AUDIO_DEVICE_STATUS_INIT_CAPTURE_SUCCESS = 0,  // Callback on successful initialization of audio capture device
  THUNDER_AUDIO_DEVICE_STATUS_INIT_CAPTURE_ERROR_OR_NO_PERMISSION = 1, // Callback on initialization failure of audio capture. It may be caused by no permission
  THUNDER_AUDIO_DEVICE_STATUS_RELEASE_CAPTURE_SUCCESS = 2, // Callback on successful release of audio capture device
};

// Network connection status 
enum ThunderConnectionStatus
{
  THUNDER_CONNECTION_STATUS_CONNECTING = 0, // Connecting
  THUNDER_CONNECTION_STATUS_CONNECTED = 1, // Connected
  THUNDER_CONNECTION_STATUS_DISCONNECTED = 2, // Disconnected
};

enum ThunderVideoMirrorMode
{
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR = 0, // The preview other than stream publishing is mirrored
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR = 1, // Both preview and stream publishing are not mirrored
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR = 2, // Neither preview and stream publishing is not mirrored
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR = 3, // The stream publishing other than preview is mirrored
};

enum NetworkQuality
{
  THUNDER_QUALITY_UNKNOWN = 0, // Unknown quality
  THUNDER_QUALITY_EXCELLENT = 1, // Excellent network quality
  THUNDER_QUALITY_GOOD = 2, // Good network quality
  THUNDER_QUALITY_POOR = 3, // The network quality is poor, but the communication is not affected even the user can feel its defects.
  THUNDER_QUALITY_BAD = 4, // The network quality is bad, and the communication can be barely made but is not smooth
  THUNDER_QUALITY_VBAD = 5, // The network quality is very bad, the communication cannot be made basically
  THUNDER_QUALITY_DOWN = 6 // Network disconnected and communication failed.
};

enum ThunderCaptureStatus
{
  THUNDER_VIDEO_CAPTURE_STATUS_SUCCESS = 0, // Succeeded
  THUNDER_VIDEO_CAPTURE_STATUS_AUTHORIZED = 1, // Permission not granted to users yet (not supported on PCs temporarily)
  THUNDER_VIDEO_CAPTURE_STATUS_NOT_DETERMINED = 2, // Permission not granted yet (not supported on PCs temporarily)
  THUNDER_VIDEO_CAPTURE_STATUS_RESTRICTED = 3, // Occupied
  THUNDER_VIDEO_CAPTURE_STATUS_DENIED = 4, // No permission
  THUNDER_VIDEO_CAPTURE_STATUS_CLOSE = 5, // Close
  THUNDER_VIDEO_CAPTURE_STATUS_LOST = 6, // The device is removed.
  THUNDER_VIDEO_CAPTURE_STATUS_RESUME = 7, // The device is removed and inserted again.
};

/**
 @brief onRecordAudioFrame 的使用模式
*/
enum ThunderAudioRawFrameOperationMode
{
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_READ_ONLY = 1, // Read only mode. The user only acquires original data from AudioFrame
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_WRITE_ONLY = 2, // Write only mode. The user replaces data in AudioFrame for encoding transmission of SDK
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_READ_WRITE = 3, // Read-write mode. The user obtains data from AudioFrame and modifies data. Then the data is returned to SDK for encoding and transmission.
};

enum MEDIA_DEVICE_TYPE
{
	/** -1: Unknown device type.
	*/
	UNKNOWN_AUDIO_DEVICE = -1,
	/** 0: Audio playback device.
	*/
	AUDIO_PLAYOUT_DEVICE = 0,
	/** 1: Audio recording device.
	*/
	AUDIO_RECORDING_DEVICE = 1,
	/** 2: Video renderer.
	*/
	VIDEO_RENDER_DEVICE = 2,
	/** 3: Video capturer.
	*/
	VIDEO_CAPTURE_DEVICE = 3,
	/** 4: Application audio playback device.
	*/
	AUDIO_APPLICATION_PLAYOUT_DEVICE = 4,
};

/** Media device states.
*/
enum MEDIA_DEVICE_STATE_TYPE
{
	/** 1: The device is active.
	*/
	MEDIA_DEVICE_STATE_ACTIVE = 1,
	/** 2: The device is disabled.
	*/
	MEDIA_DEVICE_STATE_DISABLED = 2,
	/** 4: The device is not present.
	*/
	MEDIA_DEVICE_STATE_NOT_PRESENT = 4,
	/** 8: The device is unplugged.
	*/
	MEDIA_DEVICE_STATE_UNPLUGGED = 8
};

// 远端音频流状态
enum REMOTE_AUDIO_STATE
{
  THUNDER_REMOTE_AUDIO_STATE_STOPPED = 0, // 远端音频流默认初始状态。 在 THUNDER_REMOTE_AUDIO_REASON_LOCAL_STOPPED(4) 或 THUNDER_REMOTE_AUDIO_REASON_REMOTE_STOPPED(6)  的情况下，会报告该状态
  THUNDER_REMOTE_AUDIO_STATE_STARTING = 1, // 本地用户已接收远端音频首包
  THUNDER_REMOTE_AUDIO_STATE_DECODING = 2, // 远端音频流正在解码，正常播放
  THUNDER_REMOTE_AUDIO_STATE_FROZEN = 3, // 远端音频流卡顿。在 THUNDER_REMOTE_AUDIO_REASON_NETWORK_CONGESTION(2) 的情况下，会报告该状态
  THUNDER_REMOTE_AUDIO_STATE_FAILED = 4, // 远端音频流播放失败。在THUNDER_REMOTE_AUDIO_REASON_INTERNAL(1)，THUNDER_REMOTE_AUDIO_REASON_PLAY_DEVICE_START_FAILED(8)，
                                         // THUNDER_REMOTE_AUDIO_REASON_FORMAT_NOT_SUPPORT(9)的情况下，会报告该状态
};

// 远端音频流状态改变的原因
enum REMOTE_AUDIO_REASON
{
  THUNDER_REMOTE_AUDIO_REASON_OK = 0, // 状态正常
  THUNDER_REMOTE_AUDIO_REASON_INTERNAL = 1, // 内部原因
  THUNDER_REMOTE_AUDIO_REASON_NETWORK_CONGESTION = 2, // 网络阻塞
  THUNDER_REMOTE_AUDIO_REASON_NETWORK_RECOVERY = 3, // 网络恢复正常
  THUNDER_REMOTE_AUDIO_REASON_LOCAL_STOPPED = 4, // 本地用户停止接收远端音频流或本地用户禁用音频模块
  THUNDER_REMOTE_AUDIO_REASON_LOCAL_STARTED = 5, // 本地用户恢复接收远端音频流或本地用户启用音频模块
  THUNDER_REMOTE_AUDIO_REASON_REMOTE_STOPPED = 6, // 远端用户停止发送音频流或远端用户禁用音频模块
  THUNDER_REMOTE_AUDIO_REASON_REMOTE_STARTED = 7, // 远端用户恢复发送音频流或远端用户启用音频模块
  THUNDER_REMOTE_AUDIO_REASON_PLAY_DEVICE_START_FAILED = 8, // 音频播放设备启动失败
  THUNDER_REMOTE_AUDIO_REASON_FORMAT_NOT_SUPPORT = 9, // 音频编码标准不支持导致解码失败
};

// 远端视频流状态
enum REMOTE_VIDEO_STATE
{
  THUNDER_REMOTE_VIDEO_STATE_STOPPED = 0, // 远端视频默认初始状态。在 THUNDER_REMOTE_VIDEO_REASON_LOCAL_STOPPED(4) 或 THUNDER_REMOTE_VIDEO_REASON_REMOTE_STOPPED(6) 的情况下，会报告该状态
  THUNDER_REMOTE_VIDEO_STATE_STARTING = 1, // 本地用户已接收远端视频首包
  THUNDER_REMOTE_VIDEO_STATE_DECODING = 2, // 远端视频流正在解码
  THUNDER_REMOTE_VIDEO_STATE_RENDERING = 3, // 远端视频流正在渲染
  THUNDER_REMOTE_VIDEO_STATE_FROZEN = 4, // 远端视频流卡顿。在 THUNDER_REMOTE_VIDEO_REASON_NETWORK_CONGESTION(2) 的情况下，会报告该状态
};

// 远端视频流状态改变的原因
enum REMOTE_VIDEO_REASON
{
  THUNDER_REMOTE_VIDEO_REASON_OK = 0, // 状态正常
  THUNDER_REMOTE_VIDEO_REASON_INTERNAL = 1, // 内部原因
  THUNDER_REMOTE_VIDEO_REASON_NETWORK_CONGESTION = 2, // 网络阻塞
  THUNDER_REMOTE_VIDEO_REASON_NETWORK_RECOVERY = 3, // 网络恢复正常
  THUNDER_REMOTE_VIDEO_REASON_LOCAL_STOPPED = 4, // 本地用户停止接收远端视频流或本地用户禁用视频模块
  THUNDER_REMOTE_VIDEO_REASON_LOCAL_STARTED = 5, // 本地用户恢复接收远端视频流或本地用户启动视频模块
  THUNDER_REMOTE_VIDEO_REASON_REMOTE_STOPPED = 6, // 远端用户停止发送视频流或远端用户禁用视频模块
  THUNDER_REMOTE_VIDEO_REASON_REMOTE_STARTED = 7, // 远端用户恢复发送视频流或远端用户启用视频模块
};

// 本地视频流状态
enum LOCAL_VIDEO_STREAM_STATUS
{
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_STOPPED = 0, // 本地视频默认初始状态
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_CAPTURING = 1, // 本地视频采集设备启动成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_PREVIEWING = 2, // 本地视频预览成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_ENCODING = 3, // 本地视频首帧编码成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_SENDING = 4, // 本地视频首帧发送成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_FAILED = 5, // 本地视频启动失败
};

// 本地视频流状态改变的原因
enum LOCAL_VIDEO_STREAM_ERROR_REASON
{
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_OK = 0, // 本地视频状态正常
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_FAILURE = 1, // 出错原因不明确
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_DEVICE_DENIED = 2, // 没有权限启动本地视频采集设备
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_DEVICE_RESTRICTED = 3, // 本地视频采集设备正在使用中
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_CAPTURE_FAILURE = 4, // 本地视频采集失败，建议检查采集设备是否正常工作
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_ENCODE_FAILURE = 5, // 本地视频编码失败
};

// 检测系统是否支持某些特性
enum FEATURE_SUPPORT
{
    FEATURE_SUPPORT_MAGAPI = 0,  //是否支持Mag API捕捉
};

// 本地文件播放事件的各种状态
enum ThunderAudioFilePlayerEvent
{
	AUDIO_PLAY_EVENT_OPEN = 1, // 打开文件
	AUDIO_PLAY_EVENT_PLAY = 2, // 开始播放
	AUDIO_PLAY_EVENT_STOP = 3, // 停止播放
	AUDIO_PLAY_EVENT_PAUSE = 4, // 暂停播放
	AUDIO_PLAY_EVENT_RESUME = 5, // 恢复播放
	AUDIO_PLAY_EVENT_END = 6, // 播放完毕
	AUDIO_PLAY_EVENT_SEEK_COMPLETE = 7, // 快进播放
};

// 本地文件播放事件的错误码
enum ThunderAudioFilePLayerErrorCode
{
	AUDIO_PLAYER_OPEN_FILE_PATH_ERROR = -4, // 文件路径错误
	AUDIO_PLAYER_OPEN_FILE_FORMAT_NOT_SUPPORT = -3, // 文件格式不支持
	AUDIO_PLAYER_OPEN_FILE_DECODER_FAILED = -2, // 文件格式解码出错
	AUDIO_PLAYER_CREATE_FILE_DECODER_FAILED = -1, // 文件格式解析出错
	AUDIO_PLAYER_STATUS_SUCCESS = 0, // 成功
};

class IAudioFrameObserver
{
public:
	enum AUDIO_FRAME_TYPE
	{
		FRAME_TYPE_PCM16 = 0, // PCM 16bit little endian
	};

	struct AudioFrame
	{
		AUDIO_FRAME_TYPE type;

		int samples; // Sample quantity of the frame
		int bytesPerSample; // Bytes per sample: PCM (16 digits) contains two types
		int channels; // Quantity of channels (crossed data for stereo); 1: single track, 2: dual track
		int samplesPerSec; // Sampling rate
		void* buffer; // data buffer

		long long renderTimeMs; // Not used momentarily
		int avsync_type; // Not used momentarily
	};

public:
	virtual ~IAudioFrameObserver() {}

	// Callback on original audio capture data
	virtual bool onRecordAudioFrame(AudioFrame& audioFrame) = 0;
	// Callback on original audio play data
	virtual bool onPlaybackAudioFrame(AudioFrame& audioFrame) = 0;
	// Callback on original data decoded by remote audio users
	virtual bool onPlaybackAudioFrameBeforeMixing(char* uid, AudioFrame& audioFrame) = 0;
};

struct AudioDeviceInfo // Information about audio device
{
  GUID id; // Identification of audio device
  char name[MAX_DEVICE_NAME_LEN]; // Name of audio device
  char desc[MAX_DEVICE_DESC_LEN]; // Description of audio device
};

struct AudioDeviceList
{
  AudioDeviceInfo device[MAX_DEVICE_COUNT]; // List of audio devices
  int count; // Number of audio devices
};

struct AudioVolumeInfo
{
  char uid[MAX_THUNDER_UID_LEN]; // User ID
  int volume; // Volume
};

struct AudioFrame
{
  int samples; // Audio sampling rate (sampleRate)
  int bytesPerSample; // Bit rate
  int channels; // Audio sound track
  int samplesPerSec; // Bit width of sampling point (currently only 16 available)
  int bufLen; // Data length
  void* buffer; // Specific data
};

enum VIDEO_FRAME_TYPE
{
  FRAME_TYPE_YUV420 = 0, // YUV420
  FRAME_TYPE_BGRA = 30,
};

struct VideoFrame
{
  void* dataPtr[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // Pointer to each plane data in video frame
  int dataLength[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // Length of each plane data in video frame
  int dataStride[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // Step size of each plane data in video frame
  int width; // Width of video frame
  int height; // Width and height of video frame
  VIDEO_FRAME_TYPE type; // Type of video frame
  int rotation; // Rotation angle
  __int64 timeStamp; // Presentation timestamp
};

struct VideoDeviceInfo
{
  char name[MAX_DEVICE_NAME_LEN]; // Name of video device
  int index; // Index of video device
};

struct VideoDeviceList
{
  VideoDeviceInfo device[MAX_DEVICE_COUNT]; // List of video devices
  int count; // Number of video devices
};

struct MonitorDeviceInfo
{
  int index; // Acquired device number
  int flags; // Flags for screen attributes. The following table lists the possible values:
             // 0: This screen is not the home screen.
             // 1: This screen is the home screen, can also be identified by the macro MONITORINFOF_PRIMARY came with Windows
  void* handle; // pHandler to display monitor <==> HMONITOR
  RECT rcWork; // Rectangular working area of specified screen, represented in virtual screen coordinates
  RECT rcMonitor; // Rectangular specified screen, represented in virtual screen coordinates
  char name[MAX_DEVICE_NAME_LEN]; // Device name
};

struct MonitorDeviceList
{
  int count; // Number of video devices
  MonitorDeviceInfo device[MAX_DEVICE_COUNT]; // List of video devices
};

struct VideoEncoderConfiguration
{
  VideoPublishPlayType playType;
  VideoPublishMode publishMode;
};

struct VideoCanvas
{
  HWND hWnd;  // Video rendering window
  VideoRenderMode renderMode; // Video rendering mode
  char uid[MAX_THUNDER_UID_LEN]; // User ID
};

struct FirstRenderInfo
{
  HWND hwnd; // Video rendering window
  unsigned long timeStamp; // Video rendering time
};

struct CustomAudioOptions
{
  int sampleRate; // Sampling rate (48k,44.1,16k,8k)
  int channels; // Audio channel
  int bitpersample; // Bit width of sampling point (currently only 16 available)
  bool bMixSdkCapture; // Whether to synthesize the capture of SDK itself
};

struct CustomVideoOptions
{
  enum CustomVideoSrcDataType
  {
    DATA_TYPE_I420 = 0,
    DATA_TYPE_NV12 = 1,
    DATA_TYPE_BGR24 = 2,
    DATA_TYPE_BGRA = 3,
  };

  int srcWidth; // Width and height of input source [dynamic update not available]
  int srcHeight; // Height of input source [dynamic update not available]
  int destWidth; // Width and height of output stream [this parameter has been deprecated and needs to be set according to the interface setVideoEncoderConfig]
  int destHeight; // Width and height of output stream [this parameter has been deprecated and needs to be set according to the interface setVideoEncoderConfig]
  int codeRate; // Specific value of bit rate (unit: kbps) [this parameter has been deprecated and needs to be set according to the interface setVideoEncoderConfig]
  CustomVideoSrcDataType srcDataType; // Data type of source stream
};

struct ThunderBoltImage
{
  int x; // Take the upper left corner as the original point, horizontal coordinate
  int y; // Take the upper left corner as the original point, vertical coordinate
  int width; // Width
  int height; // Height
  char url[MAX_THUNDER_URL_LEN]; // Absolute path address or http, https address of local picture
};

struct TranscodingUser
{
  TranscodingUser()
    : bStandard(false)
    , layoutX(0)
    , layoutY(0)
    , layoutW(0)
    , layoutH(0)
    , zOrder(0)
    , bCrop(false)
    , cropX(0)
    , cropY(0)
    , cropW(0)
    , cropH(0)
    , alpha(0)
    , audioChannel(0)
  {
  }

  bool bStandard; // Standard stream user or not
  int layoutX; // User's location x in video mixing canvas
  int layoutY; // User's location y in video mixing canvas
  int layoutW; // User’s width in video mixing canvas
  int layoutH; // User’s height in video mixing canvas
  int zOrder; // Layer number of the user’s video frame on the live video. The value range is the integer in [0, 100] (0 = lowest layer, 1 = first layer from bottom to top, and so on)
  bool bCrop; // 0: display in the middle after zooming, mend black edges on the upper and lower / left and right sides; 1: crop in the middle after zooming, and crop the upper and lower / left and right extra regions
  int cropX; // X coordinate of crop region, left blank means default to center cropping
  int cropY; // Y coordinate of crop region
  int cropW; // Width of crop region
  int cropH; // Height of crop region
  float alpha; // Transparency of user video on the live video. The value range is [0.0, 1.0]. 0.0 indicates that the image in this region is completely transparent, while 1.0
               // indicates completely opaque. The default is 1.0
  int audioChannel; // Not yet realized
  char uid[MAX_THUNDER_UID_LEN];
  char roomId[MAX_THUNDER_ROOMID_LEN];
};

struct LiveTranscoding
{
  // Audio is unified by default to "encode": 1,"bitrate":128,"sample":44100,"channel":2
  enum TranscodingMode
  {
    TRANSCODING_MODE_320X180 = 1, // "encode":100,"bitrate":150,"fps":15,"gop":30,"height":180,"width":320
    TRANSCODING_MODE_320X240 = 2, // "encode":100,"bitrate":200,"fps":15,"gop":30,"height":240,"width":320
    TRANSCODING_MODE_640X360 = 3, // "encode":100,"bitrate":500,"fps":15,"gop":30,"height":360,"width":640
    TRANSCODING_MODE_640X480 = 4, // "encode":100,"bitrate":500,"fps":15,"gop":30,"height":480,"width":640
    TRANSCODING_MODE_960X544 = 5, // "encode":100,"bitrate":1000,"fps":24,"gop":48,"height":544,"width":960
    TRANSCODING_MODE_1280X720 = 6, // "encode":100,"bitrate":1600,"fps":24,"gop":48,"height":720,"width":1280
    TRANSCODING_MODE_1920X1080 = 7, // "encode":100,"bitrate":4500,"fps":24,"gop":48,"height":1080,"width":1920
  };

  LiveTranscoding() : transcodingMode(0), userCount(0) {}

  int transcodingMode; // Transcoding bracket (enum TranscodingMode)
  int userCount;
  TranscodingUser userList[MAX_THUNDER_TRANSCODINGUSER_COUNT];
};

enum ThunderPublishCDNErrorCode
{
  THUNDER_PUBLISH_CDN_ERR_SUCCESS = 0, // Stream publishing succeeded
  THUNDER_PUBLISH_CDN_ERR_TOCDN_FAILED = 1, // Publishing stream to external server (CDN) is failed. 1. Check whether the URL is correct. 2.
                                            // Check whether the token in the URL is valid (generally, token is required during cdn stream publishing and can be ignored if it doe not exist)
  THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_FAILED =
    2, // Publishing the stream to thunder internal server is failed. 1. Check the anchor uplink network, 2. Contact us to locate internal transmission faults.
  THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_STOP = 3, // Stop stream publishing
};

struct RoomStats
{
  int totalDuration; // 加入频道后累计通话时长,单位为秒
  int txBitrate; // Chain sending bit rate (unit: bps)
  int rxBitrate; // Chain receiving bit rate (unit: bps)
  int txBytes; // 加入频道后累计发送字节数
  int rxBytes; // 加入频道后累计接收字节数
  int txAudioBytes; // 加入频道后累计发送音频字节数
  int rxAudioBytes; // 加入频道后累计接收音频字节数
  int txVideoBytes; // 加入频道后累计发送视频字节数
  int rxVideoBytes; // 加入频道后累计接收视频字节数
  int txAudioBitrate; // Audio packet sending bit rate (unit: bps)
  int rxAudioBitrate; // Audio packet receiving bit rate (unit: bps)
  int txVideoBitrate; // Video packet sending bit rate (unit: bps)
  int rxVideoBitrate; // Video packet receiving bit rate (unit: bps)
  int lastmileDelay;  // 本地客户端到边缘服务器的延迟（毫秒)，音频和视频延时中的较大值
};

enum ThunderSendAppMsgDataFailedStatus
{
  THUNDER_SEND_APP_DATA_HIGHT_FREQUENCY = 1, // Excessively high sending frequency. Fewer than twice each second is recommended.
  THUNDER_SEND_APP_DATA_LARGE_MSG_DATA = 2, // Excessively large size of sent data each time. It is recommended that data sent each time does not exceed 200 bytes.
  THUNDER_SEND_APP_DATA_NO_PUBLISH_SUCCESS = 3, // Publishing failed
};

enum VIDEO_CODEC_TYPE
{
  VIDEO_CODEC_UNKNOW = 0,
  VIDEO_CODEC_VP8 = 1,      //Standard VP8
  VIDEO_CODEC_H264 = 2,     //Standard H264
  VIDEO_CODEC_H265 = 3,     //Standard H265
  VIDEO_CODEC_EVP = 4,      //Enhanced VP8
  VIDEO_CODEC_E264 = 5,     //Enhanced H264
};

enum VIDEO_ENCODED_TYPE
{
  VIDEO_ENCODED_TYPE_UNKNOWN = 0,
  VIDEO_ENCODED_TYPE_HARD = 1, // 硬编
  VIDEO_ENCODED_TYPE_SOFT = 2, // 软编
};

enum QUALITY_ADAPT_INDICATION
{
  ADAPT_NONE = 0,           //The quality of local video is constant
  ADAPT_UP_BANDWIDTH = 1,   //The quality of local video has been improved because of higher network bandwidth
  ADAPT_DOWN_BANDWIDTH = 2, //The quality of local video becomes worse because of lower network bandwidth
};

struct LocalVideoStats
{
  int sendBitrate;// Actual sending bit rate (unit: Kbps), with the exception of sending bit rate of reloaded videos after packet loss
  int sendFrameRate;// Actual sending frame rate (unit: fps), with the exception of sending frame rate of reloaded videos after packet loss
  int encoderOutputFrameRate;// Output frame rate of local coder (unit: fps)
  int rendererOutputFrameRate;// Output frame rate of local preview (unit: fps)
  int targetBitrate;// Target encoding bit rate of current encoder (unit: Kbps). This bit rate is a value estimated by this SDK in accordance with current network status.
  int targetFrameRate;// Target encoding frame rate of current encoder (unit: fps). This frame rate is a value estimated by this SDK in accordance with current network status.
  QUALITY_ADAPT_INDICATION qualityAdaptIndication;//Quality adaptability of local videos since last statistics (based on target frame rate and target bit rate) 
  int encodedBitrate;//Encoding bit rate of video (Kbps). This parameter includes no encoding bit rate of reloaded videos after packet loss.
  int encodedFrameWidth;// Encoded video width (px)
  int encodedFrameHeight;// Encoded video height (px)
  int encodedFrameCount;// Number of frames sent by video, an accumulated value
  VIDEO_ENCODED_TYPE encodedType;// 编码形式
  VIDEO_CODEC_TYPE codecType;// Encoding type of videos
  int configBitRate;//Configured bit rate (kbps)
  int configFrameRate;// Configured frame rate
  int configWidth;// Configured encoding width
  int configHeight;// Configured encoding height
};

struct LocalAudioStats 
{
  int encodeBitrate; // 编码码率kbps
	int numChannels;    // Quantity of tracks
	int sendSampleRate; // Sampling rate sent (unit: Hz)
	int sendBitrate;    // Average value of bit rate of sent data (unit: Kbps)
  int enableVad; // 发送的音频流采用的VAD，0：不开启；1：开启
};

enum REMOTE_VIDEO_STREAM_TYPE
{
  REMOTE_VIDEO_STREAM_HIGH = 0,  // High stream
  REMOTE_VIDEO_STREAM_LOW = 1,   // Low stream
};

struct RemoteVideoStats
{
  int delay; // Delay from publishing remote video stream to playback
  int width; // Width of remote video stream
  int height; // Height of remote video stream
  int receivedBitrate; // Receiving bit rate (unit: Kbps)
  int decoderOutputFrameRate; // Output frame rate of remote video decoder (unit: fps)
  int rendererOutputFrameRate; // Output frame rate of remote video renderer (unit: fps)
  int packetLossRate; // Packet loss rate (%) of remote video after network confrontation
  REMOTE_VIDEO_STREAM_TYPE rxStreamType; // Types of video stream, including large stream and small stream
  int totalFrozenTime; // The accumulated time (ms) from the time when a remote user joins a channel to the time of video freezing
  int frozenRate; // The percentage (%) of the accumulated time (from the time when a remote user joins a channel to the time of video freezing) accounting for total effective time of videos
};

struct RemoteAudioStats
{
    int quality;// Quality of audio streams sent by remote users. 0: Unknown; 1: Excellent; 2: Good; 3: Poor, flawed but does not affect communication; 4: Bad, communication can be made but not smoothly; 5: Very Bad, communication can barely be made; 6: Disconnected, communication can not be made at all 
    int networkTransportDelay;// Network delay from an audio sending end to an audio receiving end
    int jitterBufferDelay;// Delay from a receiving end to network jitter buffer
    int totalDelay;// 主播采集音频到观众播放音频的总延时
    int frameLossRate;// Frame loss rate (%) of remote audio streams
    int numChannels;// Quantity of tracks
    int receivedSampleRate;// Sampling rate (Hz) of remote audios
    int receivedBitrate;// Average bit rate of remote audios within a statistical period
    int totalFrozenTime;// The accumulated time (ms) from the time when a remote user joins a channel to the time of audio freezing
    int frozenRate;// The percentage (%) of the accumulated time (from the time when a remote user joins a channel to the time of audio freezing) accounting for total effective time of audios

};

struct ThunderVideoEncodeParam
{
	int width; // 编码宽
	int height; // 编码高
	int frameRate; // 编码码率
	int codeRate; // 编码帧率
};

struct DeviceStats
{
  double cpuTotalUsage; // 当前系统的 CPU 使用率(%)
  double cpuAppUsage; // 当前 App 的 CPU 使用率 (%)
  double memoryAppUsage; // 当前 App 的内存占比 (%)
  double memoryTotalUsage; // 当前系统的内存占比 (%)
};

enum LOCAL_AUDIO_STREAM_STATUS
{
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_STOPPED = 0, // 本地音频默认初始状态
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_CAPTURING = 1, // 本地音频录制设备启动成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_ENCODING = 2, // 本地音频首帧编码成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_SENDING = 3, // 本地音频首帧发送成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_FAILED = 4, // 本地音频启动失败
};

enum LOCAL_AUDIO_STREAM_ERROR_REASON
{
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_OK = 0, // 状态正常
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_UNKNOWN = 1, // 本地音频错误原因未知
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_CAPTURE_FAILURE = 2, // 本地音频采集失败
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_ENCODE_FAILURE = 3, // 本地音频编码失败
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_FAILURE = 11, // 本地音频错误原因未知,“已废弃”.建议使用"THUNDER_LOCAL_AUDIO_STREAM_ERROR_UNKNOWN"枚举
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_DEVICE_DENIED = 12, // 没有权限启动本地音频录制设备,“已废弃”.建议使用"THUNDER_LOCAL_AUDIO_STREAM_ERROR_CAPTURE_FAILURE"枚举
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_DEVICE_RESTRICTED = 13, // 本地音频录制设备已经在使用中,"已废弃".建议使用"THUNDER_LOCAL_AUDIO_STREAM_ERROR_CAPTURE_FAILURE"枚举
};

/**
 * @brief 混响参数
 */
struct ReverbParameter
{
  float roomSize; // 房间大小; 范围: [0~100]
  float preDelay; // 预延时; 范围: [0~200]
  float reverberance; // 混响度; 范围: [0~100]
  float hfDamping; // 高频因子; 范围: [0~100]
  float toneLow; // 低频量; 范围: [0~100]
  float toneHigh; // 高频量; 范围: [0~100]
  float wetGain; // 湿增益; 范围: [-20~10]
  float dryGain; // 干增益; 范围: [-20~10]
  float stereoWidth; // 立体声宽度; 范围: [0~100]
};

/**
 * @brief limiter参数
 */
struct LimiterParameter
{
  float ceiling; // 目标阈值，范围: [-30 ~ 0]
  float threshold; // 限制阈值，范围: [-10 ~ 0]
  float preGain; // 前增益，范围: [0 ~ 30]
  float release; // 释放时间，范围: [0 ~ 1000]
  float attack; // 冲击时间，范围: [0 ~ 1000]
  float lookahead; // 前瞻值，范围: [0 ~ 8]
  float lookaheadRatio; // 前瞻比例，范围: [0.5 ~ 2]
  float rootMeanSquare; // rms值，范围: [0 ~ 100]
  float stLink; // stereo值，范围: [0 ~ 1]
};

/**
 * @brief 均衡器参数
 */
struct EqualizerParameter
{
  float amplitudeGain; // 幅度增益(db)，范围: [-12 ~ 12]
  float gains[10]; // 10个频带的增益，每个频带的增益范围: [-12 ~ 12]
                   // 每个频带的中心频率分别为31hz，62hz，125hz，250hz，500hz，1000hz，2000hz，4000hz，8000hz，16000hz
};

// 回调
class IThunderEventHandler
{
 public:
  virtual ~IThunderEventHandler() {}

  /**
 @brief Notification of joining room succeeded
 @param [OUT] room Room name
 @param [OUT] uid User ID
 @param [OUT] elapsed Indicates the time spent on joining room, that is, time elapsed (in millisecond) from calling joinRoom to event occurrence.
 @remark After joinRoom is called, receiving such a notification indicates that connection with the server is normal, and the interface that can only be called for "joining room successfully" may be called.
  */
  virtual void onJoinRoomSuccess(const char* roomId, const char* uid, int elapsed) {}

  /**
  @brief notification of leaving room
  @remark When leaveRoom is called, this notification will be received upon normal leaving of the room.
  */
  virtual void onLeaveRoom() {}

  /**
  @brief Playing volume notification
  @param [OUT] speakers Speakers
  @param [OUT] speakerCount Number of speakers
  @param [OUT] totalVolume Total volume (after audio mixing) [0-100]
  @remark After setting the setAudioVolumeIndication, you will receive the notification when someone speaks in the room
  */
  virtual void onPlayVolumeIndication(const AudioVolumeInfo* speakers, int speakerCount, int totalVolume) {}

  /**
  @brief Notification of input volume for voice test
  @param [OUT] volume Volume value
  @remark You will receive this notification when calling startInputDeviceTest, and the notification frequency is 120 ms
  */
  virtual void onInputVolume(unsigned volume) {}

  /**
  @brief Notification of output volume for voice test
  @param [OUT] volume Volume value
  @remark You will receive this notification when calling startOutputDeviceTest, and the notification frequency is 150 ms
  */
  virtual void onOutputVolume(unsigned volume) {}

  /**
 @brief Notification on service authentication results
 @param [OUT] bPublish Publishing (speaking as an anchor) or not
 @param [OUT] bizAuthResult Authentication result; 0 indicates pass; other values indicate fail (defined by the developer; SDK is only for pass-through)
 @remark The notification is received if service authentication is mandatory for services and media stream uplinks
  */
  virtual void onBizAuthResult(bool bPublish, AUTH_RESULT result) {}

  /**
 @brief SDK authentication result notification; For details about authentication, see "User Authentication Instructions" on the official website.
 @param [OUT] result Authentication results
 @remark After joinRoom is called, if the uplink and downlink media data is available, the authentication notification for the user will be received.
  */
  virtual void onSdkAuthResult(AUTH_RESULT result) {}

  /**
   @ brief Notification for token expired
   @ remark will receive this notification when user’s token Forwarding expired
  */
  virtual void onTokenWillExpire(const char* token) {}

  /**
    @brief Token Notification for token expired
    @remark You will receive this notification when user’s token is expired
  */
  virtual void onTokenRequest() {}

  /**
 @brief Notification of user banned
 @param [OUT] status Banning status true:Ban false: Unban
 @remark The callback is received if the user banning status changes.
  */
  virtual void onUserBanned(bool status) {}

  /**
  @brief Notification for users joining the current room 
  @param [OUT] uid User ID
  @param [OUT] elapsed Elapsed time, that is, the time elapsed (in milliseconds) from calling joinRoom to the occurrence of this event
  @remark After local users enter the room, if other users enter the room too, you will receive the notification, which is only effective in the audio-only mode
  */
  virtual void onUserJoined(const char* uid, int elapsed) {}

  /**
 @brief Notification of remote user leaving current room
 @param [OUT] uid User ID
 @param [OUT] reason Reason for going offline
 @remark It is valid only in audio-only mode and is returned when other users leave the room where the local user has entered.
  */
  virtual void onUserOffline(const char* uid, USER_OFFLINE_REASON_TYPE reason) {}

  /**
  @brief Notification of users' uplink and downlink network quality report 
  @param [OUT] uid User ID
  @param [OUT] txQuality The user's uplink network quality
  @param [OUT] rxQuality The user's downlink network quality
  */
  virtual void onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality) {}

  /**
  @brief Notification of successfully sending the first-frame local video
  @param [OUT] elapsed Elapsed time, that is, the time elapsed (in milliseconds) from calling joinRoom to the occurrence of this event
  @remark Users will receive this notification when they upload upstream video streams
  */
  virtual void onFirstLocalVideoFrameSent(int elapsed) {}

  /**
  @brief Notification of successfully senting the first-frame local audio  
  @param [OUT] elapsed Elapsed time, that is, the time elapsed (in milliseconds) from calling joinRoom to the occurrence of this event
  @remark Users will receive this notification when they upload upstream audio streams
  */
  virtual void onFirstLocalAudioFrameSent(int elapsed) {}

  /**
  @brief Notification of enabling/disabling audio stream of remote users
  @param [OUT] uid User id
  @param [OUT] stop true: The audio stream stops false: the audio stream starts
  @remark After calling joinRoom, you will receive this notification when the state of audio streams stored in the room and subsequent audio streams changes
  */
  virtual void onRemoteAudioStopped(const char* uid, bool stop) {}

  /**
 @brief Notification of network connection status between the SDK and the server
 @param [OUT] status Network connection status
 @remark After joinRoom is called, the notification will be received when the network connection status between the SDK and the server changes.
  */
  virtual void onConnectionStatus(ThunderConnectionStatus status) {}

  /**
     * Notification for disconnecting from the server network
     * After calling joinRoom, you will receive this notification while SDK is disconnected with server network
  */
  virtual void onConnectionLost() {}

  /**
  @brief Notification of enabling/disabling video stream of remote users
  @param [OUT] uid User id
  @param [OUT] stop true: The video stream stops false: the video stream starts
  @remark After calling joinRoom, you will receive this notification when the state of video streams stored in the room and subsequent video streams changes
  */
  virtual void onRemoteVideoStopped(const char* uid, bool stop) {}

  /**
  @brief Notification of local or remote video resolution changing
  @param [OUT] uid User id
  @param [OUT] width Width
  @param [OUT] height Height
   @param [OUT] rotation Reserved definition, not implemented
  @remark After calling joinRoom, you will receive this notification when the video resolution changes
  */
  virtual void onVideoSizeChanged(const char* uid, int width, int height, int rotation) {}

   /**
  @brief Notification of  displayed first remote video frame
  @param [OUT] uid User ID
  @param [OUT] width Width
  @param [OUT] height Height
  @param [OUT] elapsed Time elapsed (in millisecond) from calling joinRoom to event occurrence.
  @remark After setRemoteVideoCanvas is called, the notification will be received when video streams are received and displayed in the window.
  */
  virtual void onRemoteVideoPlay(const char* uid, int width, int height, int elapsed) {}

  /**
 @brief Notification of network type change
  @param [OUT] type Current network status
  @remark After initialization, the notification will be received when the network type changes.
  */
  virtual void onNetworkTypeChanged(ThunderNetworkType type) {}

  /**
  @brief Notification of the audio device capture status changing
  @param [OUT] type The audio device capture status
  @remark Start audio capture, and you will receive this notification when the audio capture status changes
  */
  virtual void onAudioCaptureStatus(ThunderAudioDeviceStatus type) {}

  /**
  @brief Callback on the plug-in and plug-out state of audio devices, such as microphone and headset
  @param [OUT] deviceId Audio device ID
  @param [OUT] deviceType Audio device type
  @param [OUT] deviceState audio device state
  @remark You will receive this notification when plugging in or plugging out the microphone or headset
  */
  virtual void OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState) {}

  /**
  @brief 视频设备状态变化回调，比如插拔摄像头
  @param [OUT] deviceId 视频设备ID
  @param [OUT] deviceType 设备类型
  @param [OUT] deviceState 视频设备状态
  @remark 插拔摄像头，会收到该通知；注意deviceId和VideoDeviceInfo.index对应
  */
  virtual void onVideoDeviceStateChanged(const char* deviceId, MEDIA_DEVICE_TYPE deviceType, MEDIA_DEVICE_STATE_TYPE deviceState) {}

  /**
  @brief CDN Notification of stream publishing result
  @param [OUT] url URL for stream publishing
  @param [OUT] errorCode Error code for stream publishing
  @remark When calling addPublishOriginStreamUrl or addPublishTranscodingStreamUrl for stream publishing, if the state changes, users will receive this notification
  */
  virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode) {}

  /**
 @brief Notification of upstream/downstream traffic (periodic notification sent once every 2 seconds)
 @param [OUT] stats speficic status
 @remark This notification is received when the user enters a channel.
  */
  virtual void onRoomStats(RoomStats stats) {}

  /**
  @brief Notification of the service-customized broadcast message
  @param [OUT] uid The uid that sends the message
  @param [OUT] msgData The received service-customized broadcast message
  @remark When the anchor sends data through sendUserAppMsgData, the viewers entering the channel will receive the notification
  */
  virtual void onRecvUserAppMsgData(const char* uid, const char* msgData) {}
  
  /**
  @brief Notification of failure in sending the service-customized broadcast message
  @param [OUT] int The specific reason for failure in sending the service-customized broadcast message [See ThunderSendAppMsgDataFailedStatus]
  @remark The host will receive this notification when failing to send data by calling sendUserAppMsgData
  */
  virtual void onSendAppMsgDataFailedStatus(int status) {}

  /**
  @brief Notification of the camera capture status changing
  @param [OUT] status Camera capture status [see ThunderCaptureStatus]
  */
  virtual void onVideoCaptureStatus(int status) {}

  /**
  * The callback of local video stream statistics
  * Statistics information of local video stream sent by local device is described during this callback. Callback time: 1. immediate callback when the publishing interface is called; 2. immediate callback on bracket change during the publishing; and 3. periodical callback at an interval of 2s.
  * @param stats Statistics data of local video, see LocalVideoStats for detailed definition
  */
  virtual void onLocalVideoStats(const LocalVideoStats stats) {}

  /**
     * Statistical information callback for local audio streams
     * This callback describes statistical information of audio streams sent by local device, with the callback timing: periodic callback at the interval of 2s
     * @param stats Statistical data of local audios. For details, see LocalAudioStats
  */
  virtual void onLocalAudioStats(const LocalAudioStats stats) {}

  /**
  * Statistics information callback of remote video stream
  * The end-to-end video stream status in calling of remote users is described during this callback, which is triggered once 2s for each remote user/anchor. This callback will be triggered for multiple times every 2 seconds in case that there are multiple remote users/anchors
     * @param uid Remote user/anchor ID
     * @param stats Statistical data of remote video. For details, seeRemoteVideoStats
  */
  virtual void onRemoteVideoStatsOfUid(const char* uid, const RemoteVideoStats stats) {}

  /**
  * Statistics information callback of remote audio stream
  * This callback describes end-to-end video streaming status of remote user during the call. It is triggered every 2s for each remote user/anchor. This callback will be triggered for multiple times every 2 seconds in case that there are multiple remote users/anchors
     * @param uid Remote user/anchor ID
     * @param stats Statistical data of remote video. For details, seeRemoteAudioStats
  */
  virtual void onRemoteAudioStatsOfUid(const char* uid, const RemoteAudioStats stats) {}

  /**
  * 采集音量回调
  * @param totalVolume 上行音量能量值[0-100]
  * @param cpt 采集时间戳
  * @param micVolume 仅麦克风采集的音量能量值[0-100]
  * 默认关闭，开关：enableCaptureVolumeIndication
  */
  virtual void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {}

  /**
  * 远端用户音频状态回调
  * @param uid 用户uid
  * @param state 远端用户音频状态
  * @param reason 音频处于当前状态原因
  * @param elapsed 从进频道到发生改状态经历的时间
  */
  virtual void onRemoteAudioStateChangedOfUid(const char* uid,
	  REMOTE_AUDIO_STATE state,
	  REMOTE_AUDIO_REASON reason,
	  int elapsed) {}

  /**
  * 远端用户视频状态回调
  * @param uid 用户uid
  * @param state 远端用户视频状态
  * @param reason 远端用户状态改变的原因
  * @param elapsed 从进频道到远端用户发生状态改变经历的时间
  */
  virtual void onRemoteVideoStateChangedOfUid(const char* uid,
	  REMOTE_VIDEO_STATE state,
	  REMOTE_VIDEO_REASON reason,
	  int elapsed) {}

  /**
  * 已播放远端音频首帧回调
  * @param uid 远端用户uid
  * @param elapsed 从进频道到发生改状态经历的时间
  */
  virtual void onRemoteAudioPlay(const char* uid, int elapsed) {}

  /**
  * 本地视频流状态改变回调
  * @param status 本地视频流状态，详细定义见 LOCAL_VIDEO_STREAM_STATUS
  * @param error 本地视频流状态改变的原因，详细定义见 LOCAL_VIDEO_STREAM_ERROR_REASON
  */
  virtual void onLocalVideoStatusChanged(LOCAL_VIDEO_STREAM_STATUS status, LOCAL_VIDEO_STREAM_ERROR_REASON error) {}

  /**
  * CPU/内存使用情况
  *该回调加入房间后，每两秒钟回调一次
  * @param [OUT] stats CPU/内存使用信息，详见DeviceStats
  */
  virtual void onDeviceStats(const DeviceStats& stats) {}

  /**
  * 回放、录音设备或 App 的音量发生改变
  * 设备音量发生变化时回调
  * @param deviceType 设备类型，详见MEDIA_DEVICE_TYPE
  * @param volume 音量
  * @param muted 是否静音，0：不静音；1：静音
  */
  virtual void onAudioDeviceVolumeChanged(int deviceType, int volume, bool muted) {}

  /**
  * 本地音频状态发生变化
  * 本地音频系统状态发生改变时（包括本地麦克风录制状态和音频编码状态），SDK 会触发回调报告当前本地音频状态
  * @param status 本地音频状态，详见LOCAL_AUDIO_STREAM_STATUS
  * @param errorReason 错误码，当本地音频状态为THUNDER_LOCAL_AUDIO_STREAM_STATUS_FAILE，可通过状态码检索具体原因
  */
  virtual void onLocalAudioStatusChanged(LOCAL_AUDIO_STREAM_STATUS status, LOCAL_AUDIO_STREAM_ERROR_REASON errorReason) {}

  /**
   * @brief 啸叫检测结果通知回调
   * @param [OUT] bHowling true:检测到啸叫；false:没有检测到啸叫
   * @remark (1) enableHowlingDetector(true)并且在打开麦克风的状态下才会收到该回调
   *         (2) 回调不是周期的，只有状态变化时，才会收到该回调
   *         (3) enableHowlingDetector(true)的状态下，关闭麦克风再打开麦克风会收到一次该回调
   *         (4) 麦克风打开的状态状态下，从enableHowlingDetector(false)到enableHowlingDetector(true)会收到一次该回调
   */
  virtual void onHowlingDetectResult(bool bHowling) {}
};

class IAudioDeviceManager
{
 public:
  virtual ~IAudioDeviceManager() {}

 public:
  /**
  @brief Enumerate audio input devices
  @param [OUT] devices Audio device information
  @return Return the number of audio input devices
  @remark Can be called only after "initialization"
  */
  virtual int enumInputDevices(AudioDeviceList& devices) = 0;

  /**
  @brief Set audio input devices
  @param [IN] id Audio device id
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can be called only after "initialization”
  */
  virtual int setInputtingDevice(GUID& id) = 0;

  /**
  @brief Enumerate audio input devices
  @param [OUT] devices Audio device id
  @return Return the number of audio input devices
  @remark Can only be called after "initialization"
  */
  virtual int getInputtingDevice(GUID& id) = 0;

  /**
  @brief Set the volume of the current audio input device
  @param [IN] volume The volume value to be set [0-100]
  @return 0: Success, see enum ThunderRet for other errors
  @remark can only be called after "initialization”
  */
  virtual int setInputtingVolume(int volume) = 0;

  /**
  @brief Get the volume of the current audio input device
  @param [OUT] volume The volume of the current audio input device [0-100]
  @return 0: Success, see enum ThunderRet for other errors
  @remark can only be called after "initialization”
  */
  virtual int getInputtingVolume(int& volume) = 0;

  /**
  @brief Mute/Unmute the current audio input device
  @param [IN] mute true: Mute false: Unmute Mute or Unmute
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int setInputtingMute(bool mute) = 0;

  /**
  @brief Get the mute status of the current audio input device
  @param [IN] mute true: Mute false: Unmute
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int getInputtingMute(bool& mute) = 0;

  /**
  @brief Start testing the current audio input device 
  @param [IN] indicationInterval Reserved parameter, 0 is suggested
  @return 0: success, See enum ThunderRetother for other errors
  @remark Can only be called after "initialization". After the call, you will receive the onInputVolume notification
  */
  virtual int startInputDeviceTest(int indicationInterval) = 0;

  /**
  @brief Stop the test of the current audio input device
  @return 0: success, See enum ThunderRetother for other errors
  @remark Can only be called after "initialization"
  */
  virtual int stopInputDeviceTest() = 0;

  /**
  @brief Enumerate audio input devices
  @param [OUT] devices Audio playback device
  @return Return the number of audio playing devices
  @remark Can be called only after "initialization"
  */
  virtual int enumOutputDevices(AudioDeviceList& devices) = 0;

  /**
  @brief Specify the audio playback device
  @param [IN] id Audio device id
  @return 0: success, See enum ThunderRetother for other errors
  @remark Can be called only after "initialization”
  */
  virtual int setOutputtingDevice(GUID& id) = 0;

  /**
  @brief Get the audio playing device
  @param [IN] id Audio device id
  @return 0: success, See enum ThunderRetother for other errors
  @remark Can be called only after "initialization”
  */
  virtual int getOutputtingDevice(GUID& id) = 0;

  /**
  @brief Set the volume of the current playing device
  @param [IN] volume Playing volume
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int setOuttingVolume(int volume) = 0;

  /**
  Get the volume of the current playing device
  @param [OUT] volume Playing volume
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int getOuttingVolume(int& volume) = 0;

  /**
  @brief Mute/Unmute the current playing device
  @param [IN] mute true: Mute false: Unmute Mute or Unmute
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int setOutputtingMute(bool mute) = 0;

  /**
  @brief Get the mute status of the current playing device
  @param [OUT] mute true: Mute false: Unmute
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization”
  */
  virtual int getOutputtingMute(bool& mute) = 0;

  /**
  @brief Start testing the current playing device 
  @param [IN] indicationInterval Reserved parameter, 0 is suggested
  @param [IN] audioFileName Full path of the audio file that is played, the formats supported by win7 and above: mp3, aac, wave; the system below win7 only supports wav
  @return 0: Success, See enum ThunderRetother for other errors
  @remark Can only be called after "initialization". After the call, you will receive the onInputVolume notification
  */
  virtual int startOutputDeviceTest(int indicationInterval, const char* audioFileName) = 0;

  /**
  @brief Stop the test of the current playing device
  @return 0: Success, See enum ThunderRetother for other errors
  @remark Can only be called after "initialization"
  */
  virtual int stopOutputDeviceTest() = 0;

  /**
  @brief Enable/disable microphone enhancement
  @param [IN] enabled true: Enable microphone enhancement; false: Disable microphone enhancement; Default is false
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Reset only when destroyEngine is performed
  */
  virtual int enableMicEnhancement(bool enabled) = 0;

  /**
  @brief Enable/disable microphone noise reduction
  @param [IN] enabled true: Enable microphone noise reduction; false: Disable microphone noise reduction; Default is false
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Reset only when destroyEngine is performed
  */
  virtual int enableMicDenoise(bool enabled) = 0;

  /**
  @brief Enable/disable echo cancellation
  @param [IN] enabled true: Enable echo cancellation; false: Disable echo cancellation; Default is false
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Reset only when destroyEngine is performed
  */
  virtual int enableAEC(bool enabled) = 0;

  /**
  @brief Enable/disable the automatic gain function [Auto Volume Control]
  @param [IN] enabled true: Enable/disable the automatic gain function; false: Disable the automatic gain function; Default is false
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Reset only when destroyEngine is performed
  */
  virtual int enableAGC(bool enabled) = 0;

  /**
   * @brief 启动/关闭啸叫检测
   * @param [IN] enabled true:启动啸叫检测；false:关闭啸叫检测；默认为false
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置，检测结果会通过onHowlingDetectResult通知
   */
  virtual int enableHowlingDetector(bool enabled) = 0;

  /**
   * @brief 开/关本地音效混响
   * @param [IN] enabled true:打开 false:关闭 默认关闭
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int enableVoiceReverb(bool enabled) = 0;

  /**
   * @brief 设置混响参数
   * @param [IN] parameter 具体的混响参数
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int setReverbParameter(const ReverbParameter& parameter) = 0;

  /**
   * @brief 开/关压限器
   * @param [IN] enabled true:打开; false:关闭；默认关闭
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int enableLimiter(bool enabled) = 0;

  /**
   * @brief 设置limiter参数
   * @param [IN] parameter 具体的limiter参数
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int setLimiterParameter(const LimiterParameter& parameter) = 0;

  /**
   * @brief 开/关均衡器
   * @param [IN] enabled true:打开; false:关闭；默认关闭
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int enableEqualizer(bool enabled) = 0;

  /**
   * @brief 设置limiter参数
   * @param [IN] parameter 具体的均衡器参数
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，仅在destroyEngine时重置
   */
  virtual int setEqualizerParameter(const EqualizerParameter& parameter) = 0;

  /**
   * @brief 设置语音音调
   * @param [IN] pitch 语音音调，参数范围：[-12, 12]；默认值为0
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark (1) 需要"初始化"后调用，仅在destroyEngine时重置
   *         (2) pitch取值越小，则音调越低
   */
  virtual int setVoicePitch(float pitch) = 0;
};

class IVideoDeviceManager
{
 public:
  virtual ~IVideoDeviceManager() {}

 public:
  /**
  @brief Enumerate video input devices
  @param [OUT] devices Video input device list
  @return Return the number of video input devices
  @remark Can be called after "initialization"
  */
  virtual int enumVideoDevices(VideoDeviceList& devices) = 0;

  /**
  @brief Enable the video device capture
  @param [IN] deviceIdx Video device index, you need to use the value obtained from enumVideoDevices
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int startVideoDeviceCapture(int deviceIdx) = 0;

  /**
  @brief Stop the video device capture
  @return 0: Success, see enum ThunderRetother for other errors
  @remark Call after "initialization"
  */
  virtual int stopVideoDeviceCapture() = 0;

  /**
  @brief Enumerate monitor input devices
  @param [OUT] devices Monitor input device list
  @return Return the number of video input devices
  @remark Can be called after "initialization"
  */
  virtual int enumMonitorDevices(MonitorDeviceList& devices) = 0;

  /**
   * @brief 开启视频采集设备测试（打开deviceIdx对应的摄像头，采集并渲染到hwnd上）
   * @param[IN] deviceIdx 视频设备索引，需要使用enumVideoDevices中获取的值
   * @param[IN] hwnd 视频渲染窗口 不能为NULL，会返回错误
   * @return 0:成功, 负数错误码见enum ThunderRet，正数错误码见：ThunderCaptureStatus
   * @remark 需要使用stopDeviceTest停止；不能与startVideoDeviceCapture打开同一视频设备；
   */
  virtual int startDeviceTest(int index, HWND hwnd) = 0;

  /**
   * @brief 停止视频采集设备测试
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 调用startDeviceTest之后，必需要调用该函数才能停止对应视频设备的测试
   */
  virtual int stopDeviceTest() = 0;

  /**
   * @brief 获取正在预览的设备索引
   * @param [OUT] deviceIdx 视频设备索引，对应enumVideoDevices中获取的值
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需要"初始化"后调用，返回的是startVideoDeviceCapture开启的视频设备索引
   */
  virtual int getVideoDeviceCapture(int& deviceIdx) = 0;
};

class IVideoCaptureObserver
{
 public:
  /**
  @brief Notification of local video capture data, the current data format is BGRA
  @remark Registration through registerVideoCaptureObserver is required
  */
  virtual bool onCaptureVideoFrame(VideoFrame& videoFrame) = 0;
};

class IVideoFrameObserver
{
 public:
  virtual ~IVideoFrameObserver() {}

 public:
  /**
  @brief Notification of local video preview data, the current data format is YUV420
  @remark Registration through registerVideoFrameObserver is required
  */
  virtual bool onPreviewVideoFrame(VideoFrame& videoFrame) = 0;

  /**
  @brief Notification of other users’ rendering video data, the data format is YUV420
  @remark Registration through registerVideoFrameObserver is required
  */
  virtual bool onRenderVideoFrame(const char* uid, VideoFrame& videoFrame) = 0;
};

class IThunderMediaExtraInfoObserver
{
 public:
  enum ThunderSendMediaExtraInfoFailedStatus
  {
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_DATA_EMPTY = 1, // Extra information is null
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_DATA_TOO_LARGE = 2, // Excessively large size of sent data each time
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_FREQUENCY_TOO_HIGHT = 3, // Excessively high sending frequency
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NOT_IN_ANCHOR_SYSTEM = 4, // Not an anchor system
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NO_JOIN_MEDIA = 5, // Channel not to be joined
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NO_PUBLISH_SUCCESS = 6, // Publishing failed
  };

  struct MixAudioInfo // Information about mixed audio stream
  {
    char uid[MAX_THUNDER_UID_LEN]; // User ID
    int volume;    // Volume of mixed audio stream [0,100]
  };

  struct MixAudioInfoList // List of information about mixed audio stream
  {
    int count; // Number of lists of information about mixed audio stream
    MixAudioInfo mixAudio[MAX_THUNDER_MIX_AUDIO_COUNT]; // Specific information about mixed audio stream
  };

  struct MixVideoInfo
  {
    char uid[MAX_THUNDER_UID_LEN]; // User ID
    int width; // Original width of this user's video
    int height; // Original height of this user's video
    int cropX; // X coordinate of the begin point used to crop the original video in video mixing
    int cropY; // Y coordinate of the begin point used to crop the original video in video mixing
    int cropW; // Width of the original video to be cropped in video mixing
    int cropH; // Height of the original video to be cropped in video mixing
    int layoutX; // X coordinate of the begin point of this user's video in video mixing canvas
    int layoutY; // Y coordinate of the begin point of this user's video in video mixing canvas
    int layoutW; // Width of this user's video in video mixing canvas
    int layoutH; // Height of this user's video in video mixing canvas
    int zOrder; // Layer number of this user's video frame in video mixing. The value range is the integer in [0, 100], and the minimum value is 0, indicating that the image in this region is at the lowest level
    float alpha; // Transparency of this user's video frame in video mixing.
                 // The value range is [0.0, 1.0]. 0.0 indicates that the image in this region is completely transparent, while 1.0 indicates completely opaque
  };

  struct MixVideoInfoList // List of information about mixed video streams
  {
    int count; // Number of lists of information about mixed video stream
    MixVideoInfo mixVideo[MAX_THUNDER_MIX_VIDEO_COUNT]; // Specific information about mixed video stream
  };

  /**
  @brief Notification of the failure status in sending media extra information
  @param [OUT] Failure error code For specific values, see: ThunderSendMediaExtraInfoFailedStatus
  */
  virtual void onSendMediaExtraInfoFailedStatus(int status) = 0;

  /**
  @brief Media extra information received
  @param [OUT] uid User ID
  @param [OUT] pData Media extra information
  @param [OUT] dataLen Media extra information length
  */
  virtual void onRecvMediaExtraInfo(const char* uid, const char* pData, int dataLen) = 0;

  /**
  @brief Received extra information about mixed audio stream
  @param [OUT] uid User ID
  @param [OUT] infos List of information about mixed audio stream
  */
  virtual bool onRecvMixAudioInfo(const char* uid, MixAudioInfoList& infos) = 0;

  /**
  @brief Received extra information about mixed video stream
  @param [OUT] uid User ID
  @param [OUT] infos List of information about mixed video stream
  */
  virtual bool onRecvMixVideoInfo(const char* uid, MixVideoInfoList& infos) = 0;
};

class IThunderAudioPlayerNotify
{
 public:
  virtual ~IThunderAudioPlayerNotify() {}

  /**
  @brief 该接口已经废除，不再起作用
  */
  virtual void onAudioFilePlayEnd() {}

  /**
  @brief 播放事件的各种状态
  @param [OUT] event 描述播放事件
               event = 0:NONE
               event = 1:打开文件
               event = 2:开始播放
               event = 3:停止播放
               event = 4:暂停播放
               event = 5:恢复播放
               event = 6:播放完毕
               event = 7:播放快进
  @param [OUT] errorCode,错误码描述.
               errorCode = 0:  成功
               errorCode = -1: 文件格式解析出错
               errorCode = -2: 文件格式解码出错
               errorCode = -3: 文件格式不支持
               errorCode = -4: 文件路径不存在
  */
  virtual void onAudioFileStateChange(ThunderAudioFilePlayerEvent event, ThunderAudioFilePLayerErrorCode errorCode) {}

  /**
  @brief 播放音量信息
  @param [OUT] volume 音量大小
  @param [OUT] currentMs 当时文件时长
  @param [OUT] totalMs 文件总时长
  */
  virtual void onAudioFileVolume(unsigned int volume, unsigned int currentMs, unsigned int totalMs) {}
};

class IThunderAudioPlayer
{
 public:
  virtual ~IThunderAudioPlayer() {}

 public:
  /**
  @brief Open the accompaniment file
  @param [IN] path File path
  @param [OUT] Opened successfully
  */
  virtual bool open(const char* path) = 0;

  /**
  @brief Close an accompaniment
  */
  virtual void close() = 0;

  /**
  @brief Start playing
  */
  virtual void play() = 0;

  /**
  @brief Stop playing
  */
  virtual void stop() = 0;

  /**
  @brief Pause
  */
  virtual void pause() = 0;

  /**
  @brief Resume
  */
  virtual void resume() = 0;

  /**
  @brief Jump to the specified time for playing
  @param [IN] timeMS Specified time
  */
  virtual void seek(unsigned int timeMS) = 0;

  /**
  @brief Get total playing time of a file
  */
  virtual unsigned int getTotalPlayTimeMS() = 0;

  /**
  @brief Get current playing time of a file
  */
  virtual unsigned int getCurrentPlayTimeMS() = 0;

  /**
  @brief deprecated
  */
  virtual void setPlayVolume(int volume) = 0;

  /**
  @brief Set the local playing volume of a file
  */
  virtual int setPlayerLocalVolume(int volume) = 0;

  /**
  @brief Set the remote playing volume of a file
  */
  virtual int setPlayerPublishVolume(int volume) = 0;

  /**
  @brief Get the local playing volume of a file
  */
  virtual int getPlayerLocalVolume() = 0;

  /**
  @brief Get the remote playing volume of a file
  */
  virtual int getPlayerPublishVolume() = 0;

  /**
  @brief  deprecated，【该接口从2.6.0开始已废弃】，获取音轨数
  */
  virtual int getAudioTrackCount() = 0;

  /**
  @brief deprecated，【该接口从2.6.0开始已废弃】，选择音轨
  */
  virtual int selectAudioTrack(int audioTrack) = 0;

  /**
  @brief 设置音频播放的声调
  @param [IN] val 声调值 -5, -4, -3, -2, -1, 0(normal), 1, 2, 3, 4, 5
  */
  virtual void setSemitone(int val) = 0;

  /**
  @brief 设置音频播放速率
  @param [IN] val 速率值 0.5，0.75， 1.0， 1.25，1.5，1.75，2.0
  */
  virtual void setTempo(float val) = 0;

  /**
  @brief 设置音频播放方位
  @param [IN] azimuth -90~90
  */
  virtual void setPosition(int azimuth) = 0;

  /**
  @brief 设置播放循环次数
  @brief Set a looping count
  */
  virtual int setLooping(int cycle) = 0;

  /**
  @brief deprecated，【该接口从2.6.0开始已废弃】，伴奏开播
  */
  virtual void enablePublish(bool enable) = 0;

  /**
  @brief deprecated，该接口已废弃，请使用 setPlayerEventCallback 接口
  @brief Set file callback
  */
  virtual void SetFilePlayerNotify(IThunderAudioPlayerNotify* notify) = 0;

  /*
  @brief 设置文件播放回调
  */
  virtual void setPlayerEventCallback(IThunderAudioPlayerNotify* notify) = 0;
};

/**
 * @brief 屏幕采集回调
 */
class IThunderScreenCaptureHandler
{
  /**
   * @brief 被捕捉的窗口退出时通知
   * @param [OUT] hWnd 被捕捉的窗口句柄
   */
  virtual void onWindowExit(HWND hWnd) {};

  /**
   * @brief 被捕捉的窗口最小化或隐藏时通知
   * @param [OUT] hWnd 被捕捉的窗口句柄
   */
  virtual void onWindowHiddenOrMinimize(HWND hWnd) {};

  /**
   * @brief 被捕捉的窗口被其他窗口遮挡时通知
   * @param [OUT] hWnd 被捕捉的窗口句柄
   * @param [OUT] overLapWndList 遮挡当前被捕捉窗口的窗口列表
   * @param [OUT] listLen 遮挡当前被捕捉窗口的窗口列表的长度
   * @remark 当发生窗口遮挡时回调一次，当窗口列表发生变化时回调一次
   */
  virtual void onWindowsOverLap(HWND hWnd, HWND* overLapWndList, int listLen) {};
};

class IThunderEngine
{
 public:
  /**
  @brief Destroy the IThunderEngine object
  @remark Can only be called after "initialization”
  */
  virtual void destroyEngine() = 0;

  /**
  @brief Initialize the IThunderEngine object
  @param [IN] appId is the AppID issued by the application developer
  @param [IN] sceneId Scenario Id customized by the developer to subdivide business scenarios; if you don’t need it, 0 is suggested
  @param [IN] pHandler Notification processing interface, which cannot be NULL
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "creating an instance". Reset only when destroyEngine is performed
  */
  virtual int initialize(const char* appId, int sceneId, IThunderEventHandler* pHandler) = 0;

  /**
  @brief Set the country and area of users.
  @param [IN] area Area type (default: AREA_DEFAULT (domestic))
  @return 0: Success, see enum ThunderRet for other errors
  @remark Valid only when being called before joinRoom Calling is necessary for abroad users but not for domestic users.
  */
  virtual int setArea(AREA_TYPE area) = 0;

  /**
  @brief Set whether to support string UID
  @param [IN] useStringUid Default: true
          true: string uid, supports the arrangement and combination of characters such as [A, Z], [a, z], [0,9],-, _, and the length cannot exceed 64 bytes
          false: Use 32-bit unsigned integer, only support [0-9], the maximum value is 4294967295
  @return 0: Success, See enum ThunderRet for other errors
  @remark Need to be called after "initialization" and before joinRoom, and will be reset when destroyEngine is performed, belonging to a non-public interface (not recommended if not necessary)
  */
  virtual int setUse64bitUid(bool useStringUid) = 0;

  /**
  @brief Join the room
  @param [IN] token Required for authentication, see "User Authentication Instructions" on the official website
  @param [IN] tokenLen Mark the token length
  @param [IN] roomId Room Id (unique for each AppId)
  @param [IN] uid User id, only supports the arrangement and combination of characters such as [A, Z], [a, z], [0,9],-, _, and the length cannot exceed 64 bytes
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "initialization"
          Note 1: For users of SDK version 2.2 and before, it is necessary to call the interface setUse64bitUid (false) if they need to use unsigned 32-bit uid
          Note 2: The successful return of the function only indicates request of execution succeeded, and and the sign of successfully joining the room is the receipt of the onJoinRoomSuccess notification
  */
  virtual int joinRoom(const char* token, int tokenLen, const char* roomId, const char* uid) = 0;

  /**
  @brief Leave room
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after successful joinRoom return
  */
  virtual int leaveRoom() = 0;

  /**
  @brief Update token
  @param [IN] token Required for authentication, see "User Authentication Instructions" on the official website
  @param [IN] tokenLen Mark the token length
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after successful joinRoom return
  */
  virtual int updateToken(const char* token, int tokenLen) = 0;

  /**
  @brief Set media mode
  @param [IN] mode Media mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization" and before “joining room”. Reset only when the destroyEngine is performed
  */
  virtual int setMediaMode(THUNDER_PROFILE mode) = 0;

  /**
  @brief Set the room mode
  @param [IN] mode Room mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Reset only when the destroyEngine is performed
  */
  virtual int setRoomMode(ROOM_CONFIG_TYPE mode) = 0;

  /**
  @brief Set the room mode
  @deprecated [The interface is deprecated] Use the new interface: replace setMediaMode with setRoomMode
  @param [IN] profile Media mode
  @param [IN] roomConfig Room mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization" and before “joining room”. Reset only before “entering the room”
  */
  virtual int setRoomConfig(THUNDER_PROFILE profile, ROOM_CONFIG_TYPE roomConfig) = 0;

  /**
  @brief Audio starting
  @deprecated [The interface is deprecated] It is recommended to use stopLocalAudioStream (false);
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can be called only after “entering the room”
  */
  virtual int enableAudioEngine() = 0;

  /**
  @brief Audio stopping
  @deprecated [The interface is obsolete] It is recommended to use stopLocalAudioStream (true);
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can be called only after “joining the room”
  */
  virtual int disableAudioEngine() = 0;

  /**
  @brief Set the audio mode
  @param [IN] profile Audio type
  @param [IN] commutMode Interactive mode
  @param [IN] scenarioMode Scenario mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Can be called before audio publishing
  */
  virtual int setAudioConfig(AUDIO_PROFILE_TYPE profile, COMMUT_MODE commutMode, SCENARIO_MODE scenarioMode) = 0;

  /**
  @brief Set publishing mode
  */
  virtual int setAudioSourceType(ThunderSourceType sourceType) = 0;

  /**
  @brief Disable/enable local audio (including audio encoding and uploading)
  @param [IN] stop true: Disable local audio; false: Enable local audio
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after "entering the room”
  */
  virtual int stopLocalAudioStream(bool stop) = 0;

  /**
  @brief Stop/Receive all audio data, the default is false
  @param [IN] stop true: Stop all remote audios false: Receive all remote audios
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization", reset only when the destroyEngine is performed
  To determine whether to receive or prohibit the remote user, first determine the value set by stopRemoteAudioStream; if no such value, then the value set by this function should be used
The individual settings of stopRemoteAudioStream will be cleared every time when the stopAllRemoteAudioStreams is called
  */
  virtual int stopAllRemoteAudioStreams(bool stop) = 0;

  /**
  @brief Stop/receive the specified audio data
  @param [IN] uid User id
  @param [IN] stop true: Stop user audio false: Receive user audio
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization", reset only when destroyEngine is performed
  To determine whether to receive or prohibit the remote user, first determine the value set by this function; if no such value, then the value set by set by stopRemoteAudioStream should be used
  */
  virtual int stopRemoteAudioStream(const char* uid, bool stop) = 0;

  /**
  @brief Set the local playback volume of a remote user
  @param [IN] uid User id
  @param [IN] volume Volume [0--100]
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization", reset only when destroyEngine is performed
  */
  virtual int setPlayVolume(const char* uid, int volume) = 0;

  /**
  @brief Enable speaker volume indication
  @param [IN] interval <= 0: Disable the volume indication function;> 0 interval for returning to volume indication, in milliseconds, which is recommended to be greater than 200 milliseconds
  @param [IN] smooth Reserved parameters, not yet implemented
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization", only reset when destroyEngine is performed; You will receive onPlayVolumeIndication notification if someone speaks in the room
  */
  virtual int setAudioVolumeIndication(int interval, int smooth) = 0;

  /**
  @brief 打开采集音量回调
  @param [IN] interval <=0: 禁用音量提示功能 >0: 回调间隔，单位为毫秒
  @param [IN] moreThanThd 从<moreThanThd到>=moreThanThd，立即回调一次 <=0无效
  @param [IN] lessThanThd 从>=lessThanThd到<lessThanThd，立即回调一次 <=0无效
  @param smooth 未实现
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int enableCaptureVolumeIndication(int interval, int moreThanThd, int lessThanThd, int smooth) = 0;

  /**
  @brief Enable/disable graphic card capture
  @param [IN] enabled true: Enable graphic card capture; false: Disable graphic card capture;
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization". Stop only when destroyEngine is performed
  */
  virtual int enableLoopbackRecording(bool enabled) = 0;

  /**
  @brief Start recording
  @param [IN] fileName Recording file name (full path, filename extension not included and to be generated in accordance with fileType)
  @param [IN] fileType File format
  @param [IN] quality Recording quality
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization"
  */
  virtual int startAudioRecording(const char* fileName,
                                  AUDIO_RECORDING_FILE_TYPE fileType,
                                  AUDIO_RECORDING_QUALITY_TYPE quality) = 0;

  /**
  @brief Stop recording
  @return 0: Success, See enum ThunderRetother for other errors
  @remark Call after "initialization"
  */
  virtual int stopAudioRecording() = 0;

  /**
  @brief Set microphone volume
  @param [IN] volume value range [0--400]
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int adjustRecordingSignalVolume(int volume) = 0;

  /**
  @brief Set playback volume
  @param [IN] volume value range [0--400]
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int adjustPlaybackSignalVolume(int volume) = 0;

  /**
  @brief Get the instance object of the audio device management interface  @return Object pointer of audio device management interface or NULL
  @remark Need to be called after "initialization"
  */
  virtual IAudioDeviceManager* getAudioDeviceMgr() = 0;

  /*!
  @brief Register an audio frame observer
  @param [IN] observer Audio observer object
  @remark The user shall inherit the IAudioFrameObserver interface class and duplicate four methods. These methods will be used to transfer the related original audio data to the user
  */
  virtual bool registerAudioFrameObserver(IAudioFrameObserver *observer) = 0;

  /**
  @brief Set the usage mode for audio recording original data in the onRecordAudioFrame callback
  @param [IN] sampleRate Sampling rate
  @param [IN] channel Audio track; 1: single track, 2: dual track
  @param [IN] mode Usage mode of the onRecordAudioFrame, see ThunderAudioRawFrameOperationMode for details  @param [IN] Number of sampling points for the data returned from onRecordAudioFrame specified by samplesPerCall, such as 1024 in transcoding and stream publishing applications. 
  samplesPerCall = (int)(sampleRate × sampleInterval), in which: sampleInterval ≥ 0.01, in seconds. 
  @return 0: succeeded. For other errors, see enum ThunderRet
  */
  virtual int setRecordingAudioFrameParameters(int sampleRate,
	  int channel,
	  ThunderAudioRawFrameOperationMode mode,
	  int samplesPerCall) = 0;

  /**
  Set the usage mode for audio playing original data in the onPlaybackAudioFrame callback
  @param [IN] sampleRate Sampling rate
  @param [IN] channel    Audio track; 1: single track, 2: dual track
  @param [IN] mode      Usage mode of the onRecordAudioFrame, see ThunderAudioRawFrameOperationMode for details
  @param [IN] Number of sampling points for the data returned from onRecordAudioFrame specified by samplesPerCall, such as 1024 in transcoding and stream publishing applications. 
  samplesPerCall = (int)(sampleRate × sampleInterval), in which: sampleInterval ≥ 0.01, in seconds. 
  @return 0: succeeded. For other errors, see enum ThunderRet
  */
  virtual int setPlaybackAudioFrameParameters(int sampleRate,
	  int channel,
	  ThunderAudioRawFrameOperationMode mode,
	  int samplesPerCall) = 0;

  /**
  @brief Set directory for SDK to output log files. A directory with write permissions must be specified. 
  @param [IN] filePath Complete log file directory
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int setLogFilePath(const char* filePath) = 0;

  /**
  @brief set log saving level
  @param [IN] filter log filter
  @return 0: success, other errors see enum ThunderRet
  @remark Logs with lower level (LogLevel) will be filtered. Only logs with the log level indicated by this value or higher than this value are recorded.
  */
  virtual int setLogLevel(LOG_FILTER filter) = 0;

  /**
  @brief Register the video observer object
  @param [IN] observer Object instance. If observer is NULL, then cancel the registration
  @return 0: Success, See enum ThunderRetother for other errors
  @remark Call after "initialization"
  */
  virtual int registerVideoFrameObserver(IVideoFrameObserver* observer) = 0;

  /**
  @brief Get the instance object of the video device management interface
  @return Object pointer of video device management interface or NULL
  @remark Need to be called after "initialization"
  */
  virtual IVideoDeviceManager* getVideoDeviceMgr() = 0;

  /**
  @brief Enable a video module
  @deprecated [This interface has been deprecated] The video module is available by default in the THUNDER_PROFILE_NORMAL mode
  @return 0: succeeded. For other errors, see enum ThunderRet
  @remark The interface shall be called after initialization.
  */
  virtual int enableVideoEngine() = 0;

  /**
  @brief Disable a video module
  @deprecated [This interface has been deprecated] If the video module is not required, set setMediaMode(THUNDER_PROFILE_ONLY_AUDIO)
  @return 0: succeeded. For other errors, see enum ThunderRet
  @remark The interface shall be called after initialization.
  */
  virtual int disableVideoEngine() = 0;

  /**
  @brief Set video encoding configuration
  @param [IN] config Specific encoding configuration
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int setVideoEncoderConfig(const VideoEncoderConfiguration& config) = 0;

  /**
  @brief 根据视频编码配置获取编码参数
  @param [IN] configIn 编码配置档位
  param [OUT] paramOut 具体的编码参数
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int getVideoEncoderParam(const VideoEncoderConfiguration& configIn, ThunderVideoEncodeParam& paramOut) = 0;

  /**
  @brief Set rendering view of local video
  @param [IN] local  Specific rendering settings
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark (1)The interface shall be called after initialization.
          (2)The SDK will render the anchor's video to the view when startVideoPreview.
          (3)If the user destroys the view, you need to call this API again to set "view" to "null" to unbind SDK and view.
          Otherwise, when startVideoPreview is called again, it will access the wild pointer of the view and cause a crash.
  */
  virtual int setLocalVideoCanvas(const VideoCanvas& canvas) = 0;

  /**
  @brief Set rendering view of remote video
  @param [IN] remote Specific view settings
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark (1)The interface shall be called after initialization.
          (2)The SDK automatically subscribes to the audio and video streams in the channel. After setting the remote anchor
          uid and view, the SDK will save the binding relationship between uid and view and render the video to the view.
          (3)If the user destroys the view, you need to call this API to set "view" to "null" to unbind SDK and view.
          Otherwise, if the remote host re-publishs, the SDK will access the wild pointer of the view and cause a crash. 
          when it subscribes automatically.
  */
  virtual int setRemoteVideoCanvas(const VideoCanvas& canvas) = 0;

  /**
  @brief Set the local view display mode
  @param [IN] mode Rendering display mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int setLocalCanvasScaleMode(VideoRenderMode mode) = 0;

  /**
  @brief Set the remote view display mode
  @param [IN] mode Rendering display mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int setRemoteCanvasScaleMode(VideoRenderMode mode) = 0;

  /**
  @brief Enable video preview 
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface shall be called after initialization.
  */
  virtual int startVideoPreview() = 0;

  /**
  @brief Disable video preview 
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface shall be called after initialization.
  */
  virtual int stopVideoPreview() = 0;

  /**
  @brief Enable/disable local video capture
  @param [IN] enabled true: Enable local capture false: Disable local capture;
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization"
  */
  virtual int enableLocalVideoCapture(bool enabled) = 0;

  /**
  @brief Enable/disable local video sending
  @param [IN] stop true: Enable local video sending; false: Disable local video sending
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface shall be called after initialization.
  */
  virtual int stopLocalVideoStream(bool stop) = 0;

  /**
  @brief Stop/receive designated remote videos
  @param [IN] uid User ID
  @param [IN] stop true: Stop remote videos of a designated user; false: Receive remote videos of a designated user
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface shall be called after initialization; it is reset only when destroyEngine is called.
  To determine whether to receive or stop remote videos, view the value of this function first; if this function is not set, view the value of stopAllRemoteVideoStreams.
  */
  virtual int stopRemoteVideoStream(const char* uid, bool stop) = 0;

  /**
  @brief Stop/receive all remote videos
  @param [IN] stop true: Stop all remote video streams; false: Receive all remote video streams; default value: false
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface shall be called after initialization; it is reset only when destroyEngine is called.
  To determine whether to receive or stop remote videos, view the value of stopRemoteVideoStream first; if stopRemoteVideoStream is not set, view the value of this function.
  The individual settings of stopRemoteVideoStream will be cleared when stopAllRemoteVideoStreams is called every time.
  */
  virtual int stopAllRemoteVideoStreams(bool stop) = 0;

  /**
  @brief Set local video watermark
  @param [IN] watermark Watermark image information, the URL of this interface only supports local absolute path;
  @return 0: Success, see enum ThunderRet for other errors
  @remark Need to be called after "initialization", currently only support one watermark, and those added later will replace the ones added before
          Only 24-bit and 32-bit image files are supported; the SDK will convert the images to the set width
  */
  virtual int setVideoWatermark(const ThunderBoltImage& watermark) = 0;

  /**
  @brief Clear local video watermark
  @return 0: Success, see enum ThunderRet for other errors
  @remark This method is used to clear the watermark set by setVideoWatermark
  */
  virtual int removeVideoWatermarks() = 0;

  /**
  @brief Set external audio capture parameters
  @param [IN] bEnable Whether to start audio capture
  @param [IN] option External audio capture parameters
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int setCustomAudioSource(bool bEnable, CustomAudioOptions& option) = 0;

  /**
  @brief Push external audio frames
  @param [IN] pData PCM audio frame data
  @param [IN] dataLen Data length
  @param [IN] timeStamp Capture timestamp
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int pushCustomAudioFrame(const char* pData, unsigned dataLen, unsigned timeStamp) = 0;

  /**
  @brief Set external video capture parameters
  @param [IN] bEnable Whether to enable external video
  @param [IN] option External video capture parameters
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int setCustomVideoSource(bool bEnable, CustomVideoOptions& option) = 0;

  /**
  @brief Push external video capture parameters
  @param [IN] yuv YUV data
  @param [IN] linesize Line width of the buffer in YUV data
  @param [IN] timestamp Capture timestamp
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int pushCustomVideoFrame(const unsigned char* yuv[3], int linesize[3], unsigned timestamp) = 0;

  /**
  @brief Add source stream publishing address [supporting a maximum of five stream publishing addresses]
  @param [IN] url Stream publishing address, in RTMP format; The value does not support special characters such as Chinese.
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark After publishing, the server pushes the source stream to the corresponding URL. The interface can be called after joining the room (joinRoom), and the configuration will be cleared after leaving the room.
  */
  virtual int addPublishOriginStreamUrl(const char* url) = 0;

  /**
  @brief Remove stream publishing address of source stream
  @param [IN] url Stream publishing address to be removed
  @return 0: succeeded. For other errors, see enum ThunderRet
  */
  virtual int removePublishOriginStreamUrl(const char* url) = 0;

  /**
  @brief Add/Update transcoding tasks [a maximum of 5 transcoding tasks supported in one room]
  @param [IN] taskId ID of a transcoding task, which is unique in a room and is managed by users.
              Only supports the permutation and combination of characters such as [A, Z], [a, z], [0, 9], -, _, with the length of not more than 64 bytes.
  @param  [IN] transcoding Specific transcoding layout
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark After publishing, the server performs transcoding and pushes streams (if any) according to the configured canvas. The interface can be called after joining the room (joinRoom), and the configuration will be cleared after leaving the room.
  */
  virtual int setLiveTranscodingTask(const char* taskId, const LiveTranscoding& transcodingCfg) = 0;

  /**
  @brief Remove transcoding task
  @param [IN] taskId Transcoding task identifier
  @return 0: succeeded. For other errors, see enum ThunderRet
  */
  virtual int removeLiveTranscodingTask(const char* taskId) = 0;

  /**
  @brief Add stream publishing address for transcoding stream [one transcoding task supports a maximum of five stream publishing addresses]
  @param [IN] taskId ID of a transcoding task
  @param [IN] url Stream publishing address, in RTMP format; The value does not support special characters such as Chinese.
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface can be called after joining the room (joinRoom), and the configuration will be cleared after leaving the room.
  */
  virtual int addPublishTranscodingStreamUrl(const char* taskId, const char* url) = 0;

  /**
  @brief Remove the publishing address of the transcoded stream
  @param [IN] taskId Transcoding task ID
  @param [IN] url The publishing address to be removed
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can only be called after entering the room (joinRoom)
  */
  virtual int removePublishTranscodingStreamUrl(const char* taskId, const char* url) = 0;

  /**
  @brief Subscribe to specified streams (cross-room).
  @param [IN] roomId Room number [only supports the permutation and combination of characters such as [A, Z], [a, z], [0, 9], -, _, with the length of not more than 64 bytes.]
  @param [IN] uid User ID
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface can be called after joining the room, and the configuration will be cleared after leaving the room.
  */
  virtual int addSubscribe(const char* roomId, const char* uid) = 0;

  /**
  @brief Unsubscribe from streams
  @param [IN] roomId Room number [only supporting the permutation and combination of characters such as [A, Z], [a, z], [0, 9], -, _, with the length of not more than 64 bytes.]
  @param [IN] uid User ID
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The interface can be called after joining the room
  */
  virtual int removeSubscribe(const char* roomId, const char* uid) = 0;

  /**
  @brief Enable/disable WebSDK compatibility
  @param [IN] enabled Whether to enable compatibility, disable by default
  @return 0: Success, see enum ThunderRet for other errors
  @remark Call after "initialization”. Reset only when destroyEngine is performed
  */
  virtual int enableWebSdkCompatibility(bool enabled) = 0;

  /**
  @brief Set Thunder profiles
  @param [in]  options Relevant configuration information defined in JSON
          1. Set video group subscription:"JoinWithSubscribeGroup": true
          2. Set video group publishing:"PublishAudioToGroup": true
          3. Set channel number and subchannel number: "setSid":79804098,"setSubsid":79804098
          "setSubsid":79804098,
  @return 0: Success, See enum ThunderRet for other errors
  @remark Need to be called after "initialization" and before joinRoom, and will be reset after the destroyEngine is performed, belonging to a non-public interface (not recommended if not necessary)
  */
  virtual int setParameters(const char* options) = 0;

  /**
  @brief 获取当前网络连接状态
  @return 连接状态，参见enum ThunderConnectionStatus
  @remark 需在"初始化"后调用
  */
  virtual ThunderConnectionStatus getConnectionStatus() = 0;

  /**
  @brief Send the service-customized broadcast message
  @param [IN] msgData Service-customized broadcast message
  @return 0: Success, see enum ThunderRet for other errors
  @remark This interface sends messages through the media UDP channel, which features low latency and unreliability. Specified constraints are as follows: 
          1. Sender must join the room. 
          2. Call it when microphone is opened successfully (unavailable for pure audience or upon failure of publishing authentication). 
          3. This interface should be called with a frequency of less than twice each second. msgData should not exceed 200 bytes.
          4. The msg will be dropped if any above condition is not met. 
          5. Not guaranteed to send to all online users in the room, or sent in order. 
          Note 1: Notify causes for failure in sending customized broadcast messages through onSendAppMsgDataFailedStatus
          Note 2: Customized broadcast messages sent by other users will be notified to the application through onRecvUserAppMsgData
  */
  virtual int sendUserAppMsgData(const char* msgData) = 0;

  /**
  @brief Send media extra information (audio/video publishing)
  @param [IN] extraData Media extra information
  @return 0: Succeeded; For other errors, see enum ThunderRet.
  @remark The following describes how to send media extra information in detail:
          1. The interface can be called only if the sender joins the room and audio publishing succeeds
          2. Audio publishing only: The fastest frequency for calling this interface is 100ms once, and the media extra information does not exceed 200 bytes
          3. Video publishing: The calling frequency cannot exceed the frame rate, and the media extra information does not exceed 2,048 bytes. 
          For example: The default frame rate for stream publishing is 15fps; that is, the calling frequency cannot exceed 1000/15 = 66.7 ms/time
          4. Packet loss may occur,
          5. The SDK guarantees that the media data will be called back at the time when the corresponding frame is played.
          Note 1: Notify causes for failure in sending media extra information through onSendMediaExtraInfoFailedStatus
          Note 2: Media extra information sent by other users will be notified to the application through onRecvMediaExtraInfo
  */
  virtual int sendMediaExtraInfo(const char* extraData) = 0;

  /**
  @brief Enable video mixing with media extra information
  @param [IN] enabled true: Enable video mixing with media extra information; false: Disable video mixing with media extra information; the default is false
  */
  virtual int enableMixVideoExtraInfo(bool enabled) = 0;

  /**
  @brief Set the local video mirror mode
  @param [IN] mode Mirror mode
  @return 0: Success, see enum ThunderRet for other errors
  @remark Can set local preview and the mirror mode of videos that the peer party sees, which takes effect immediately
  */
  virtual int setLocalVideoMirrorMode(ThunderVideoMirrorMode mode) = 0;

  /**
  @brief Start capturing the specified window
  @param [IN] hWnd Window handle
  @param [IN] pRect Specified sub-region of the window to be captured, with the coordinate being the relative coordinate of the window. When NULL, the entire window will be captured
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int startScreenCaptureForHwnd(HWND hWnd, const RECT* pRect) = 0;

  /**
  @brief Start capturing the specified area on the specified desktop
  @param [IN] screenId Display ID
  @param [IN] pRect Specified sub-region to be captured, with the coordinate being the relative coordinate of the display. When it is NULL,
the entire display region will be captured
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int startScreenCaptureForScreen(int screenId, const RECT* pRect) = 0;

  /**
  @brief Update capturing the specified window
  @param [IN] hWnd Window handle
  @param [IN] pRect Specified sub-region to be captured, with the coordinate being the relative coordinate of the display or window. When it is NULL, the entire monitor or window area will be captured
  @return 0: Success, see enum ThunderRet for other errors
  */
  virtual int updateScreenCaptureRect(const RECT* pRect) = 0;

  /**
  @brief Stop capturing the desktop or window
  @return 0: Success, See enum ThunderRetother for other errors
  */
  virtual int stopScreenCapture() = 0;

  /**
  @brief Pause capturing the desktop or window
  @return 0: Success, See enum ThunderRetother for other errors
  */
  virtual int pauseScreenCapture() = 0;

  /**
  @brief Resume capturing the desktop or window
  @return 0: Success, See enum ThunderRetother for other errors
  */
  virtual int resumeScreenCapture() = 0;

  /**
  * @brief 是否支持某种Feature
  * 如：FEATURE_SUPPORT_MAGAPI 查询是否支持 Magnification API捕捉。
  */
  virtual bool checkFeatureSupport(FEATURE_SUPPORT flag) = 0;

  /**
  * @brief	设置屏幕捕捉时需要排除的窗口列表
  * @param	[in] wndList 捕捉时需排除的窗口列表
  * @param	[in] count 捕捉时需排除的窗口的个数
  */
  virtual int setCaptureExcludeWindowList(HWND* wndList, int count) = 0;

  /**
  @brief Register the observer object for camera capture data 
  @param [IN] observer Object instance, if observer is NULL, then cancel the registration
  @return 0: Success, See enum ThunderRetother for other errors
  */
  virtual int registerVideoCaptureObserver(IVideoCaptureObserver* observer) = 0;

  /**
  @brief Register the observer object for media extra information
  @param [IN] observer Object instance, if observer is NULL, then cancel the registration
  @return 0: Success, See enum ThunderRetother for other errors
  */
  virtual int registerMediaExtraInfoObserver(IThunderMediaExtraInfoObserver* observer) = 0;

  /**
  @brief Create an audio player
  @return 0: Audio player object
  */
  virtual IThunderAudioPlayer* createThunderAudioPlayer() = 0;

  /**
  @brief Destroy the audio player
  */
  virtual void destroyThunderAudioPlayer(IThunderAudioPlayer* player) = 0;

  /**
   * @brief 开启/关闭远端用户的语音立体声
   * @param [IN] enabled true:开启远端用户的语音立体声；false:关闭远端用户的语音立体声；默认值为false
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需在joinRoom前调用该方法；destroyEngine时会重置
   */
  virtual int enableVoicePosition(bool enabled) = 0;

  /**
   * @brief 设置远端用户声音的空间位置和音量
   * @param [IN] uid 远端用户ID
   * @param [IN] azimuth 设置远端用户声音出现的位置，取值范围[-90,90] 0:(默认值):正前方；-90:在左边；90:右边
   * @param [IN] gain 设置远端用户声音的音量，取值范围[0,100], 默认值为100，表示该用户的原始音量。取值越小，则音量越低
   * @return 0:成功, 其它错误参见enum ThunderRet
   * @remark 需在enableVoicePosition(true)后调用该方法；退频道时会重置该函数的设置
   */
  virtual int setRemoteUidVoicePosition(const char* uid, int azimuth, int gain) = 0;

  /**
   * @brief 设置桌面采集回调
   * @param [IN] pHandler IThunderScreenCaptureHandler实例，为NULL则不回调
   * @return 0:成功, 其它错误参见enum ThunderRet
   */
  virtual int registerScreenCaptureCallback(IThunderScreenCaptureHandler* pHandler) = 0;
  
 protected:
  IThunderEngine() {}
  virtual ~IThunderEngine() {}
};
} // namespace Thunder

EXTERN_C { THUNDER_ENGINE Thunder::IThunderEngine* createEngine(); };

#endif
