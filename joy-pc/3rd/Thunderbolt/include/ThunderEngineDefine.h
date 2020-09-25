#pragma once
/*
  Note: Define the error codes and enumerated values of the platform layer here, which need to be synchronized to the definition of three platforms
  1.ios: 
  2.windows: 
  3.android:
*/
namespace Thunder
{
enum ThunderRet
{
  // Error code returned from the synchronization interface [-1 ~ -1000]
  THUNDER_RET_SUCCESS = 0, // Processing succeeded
  THUNDER_RET_NOT_INITIALIZED = -1, // Not initialized
  THUNDER_RET_WRONG_INIT_STATUS = -2, // A wrong initialization status. Before the initialization or destroying is finished, this error will be returned back when this interface is called.
  THUNDER_RET_NO_JOIN_ROOM = -3, // Not joining a room [If the interface only can be called after joining room, the error will be returned if the interface is called before joining room]
  THUNDER_RET_ALREADY_JOIN_ROOM = -4, // Already joining a room [If a interface is only called before joining room, the error will be returned when this interface is called after joining room]
  THUNDER_RET_WRONG_JOIN_STATUS = -5, // A wrong joining status. Before room joining or room quitting is finished, this error will be returned back when this interface is called.
  THUNDER_RET_NOT_IN_THUNDER = -6, // Not in a Thunder mode (This error will be returned back only if an interface called by Thunder is called in a ThunderBolt mode)
  THUNDER_RET_NOT_IN_THUNDERBOLT = -7, // Not in a ThunderBolt mode (This error will be returned back only if an interface called by ThunderBolt is called in a Thunder mode)
  THUNDER_RET_INVALID_UID = -8, // Invalid uid
  THUNDER_RET_INVALID_ROOMID = -9, // Invalid roomId
  THUNDER_RET_INVALID_URL = -10, // Invalid url
  THUNDER_RET_INVALID_TASKID = -11, // Invalid task
  THUNDER_RET_CAPACITY_LIMIT = -12, // SDK capacity limit (super-threshold of a stream publishing address)
  THUNDER_RET_INVALID_ARGUMENT = -13, // Invalid parameters (when necessary parameters are null or illegal)
  THUNDER_RET_START_AUDIO_CAPTURE_ERR = -14, // Error in starting audio capture
  THUNDER_RET_NO_START_AUDIO_CAPTURE = -15, // Not starting audio capture. In the case of not enabling capture, this error will be returned when external data is pushed.
  THUNDER_RET_ALREADY_START_AUDIO_CAPTURE = -16, // Already starting audio capture. This error will be returned when resetting is executed during capturing.
  THUNDER_RET_NO_START_AUDIO_PUBLISH = -17, // Not starting audio publishing. In the case of not starting publishing, this error will be returned when external data is pushed.
  THUNDER_RET_ALREADY_START_AUDIO_ENCODE = -18, // Audio publishing has been enabled, repeating publish setting will return this error code
  THUNDER_RET_ALREADY_START_AUDIO_PUBLISH = -19, // Audio publishing has been enabled, repeating publish setting will return this error code
  THUNDER_RET_NOT_ON_FRONT_CAMERA = -20, // This error will be returned if a camera mirror is set on a rear camera.
  THUNDER_RET_NOT_ON_MULTI_TYPE = -21, // When a multi-user microphone connection layout is set, this error will be returned if a remote play type is set before users join a room.
  THUNDER_RET_INVALID_SEATINDEX = -22, // This error will be returned when the preset seat number for multi-user microphone connection exceeds a layout setting range.

  // Video mixing related [-101 ~ -200]
  THUNDER_RET_INVALID_TRANSCODING_MODE = 101, // Invalid transcodingMode

  // Warning codes returned asynchronously [-1001 ~ -2000]

  // Error codes returned asynchronously [-2001 ~ -3000]
  THUNDER_NOTIFY_JOIN_FAIL = -2001, // Notifying that room joining fails when SDK does not receive services due to network (SDK will execute room quitting operation if the room joining fails)

  // Error codes used in the audio library [-3001 ~ -4000]
  THUNDER_RET_AUDIO_ENGINE_ERROR = -3001, // Returning an audio engine error. It is required to check logs for specific reasons.
  THUNDER_RET_AUDIO_DISABLE_VOICE_POSITION = -3002, // Not enabling voice stereo of remote users.

  // Error codes used in the video library [-4001 ~ -5000]
  THUNDER_RET_VIDEO_ENGINE_ERROR = -4001, // Returning a video engine error. It is required to check logs for specific reasons.

  // Error codes used in the transmission library [-5001 ~ -6000]
  THUNDER_RET_TRANS_ENGINE_ERROR = -5001, // Returning a transfer engine error. It is required to check logs for specific reasons.

  // Error codes used in the configuration library (argo) [-6001 ~ -7000]
  THUNDER_RET_ARGO_ENGINE_ERROR = -6001, // Returning a configuration engine error. It is required to check logs for specific reasons.

  // Error codes used in the SEVICE library [-7001 ~ -8000]
  THUNDER_RET_SERVICE_ENGINE_ERROR = -7001, // Returning a SERVICE engine error. It is required to check logs for specific reasons.

  // Error codes used in the LOG library [-8001 ~ -9000]
  THUNDER_RET_LOG_ENGINE_ERROR = -8001, // Returning a log engine error. It is required to check logs for specific reasons.
};

// Area enumeration, corresponding to the value set in interface setAreaType
enum LiveEngineAreaType
{
  THUNDER_AREA_DEFAULT = 0, // Default value (domestic)
  THUNDER_AREA_FOREIGN = 1, // Overseas
  THUNDER_AREA_RESERVED = 2, // yy-reserved
};

enum LiveEngineRoomConfig
{
  THUNDER_ROOMCONFIG_LIVE = 0, // Live streaming (high quality, without interaction mode) (shifted to medium quality and strong interaction mode when connecting microphones)
  THUNDER_ROOMCONFIG_COMMUNICATION = 1, // Communication (medium quality and strong interaction mode)
  THUNDER_ROOMCONFIG_GAME = 3, // Game (low quality and strong interaction mode)
  THUNDER_ROOMCONFIG_MULTIAUDIOROOM = 4, // Multi-person voice room (medium quality, economic traffic and strong interaction mode)
  THUNDER_ROOMCONFIG_CONFERENCE = 5, // Conference (medium quality, strong interaction mode, applicable to frequent enabling/disabling of microphones, with smooth sound in enabling/disabling microphones)
};

}; // namespace Thunder
