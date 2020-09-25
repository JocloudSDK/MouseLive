#pragma once

#include "orangefilter.h"
#include <string>
#include <vector>
#include <map>

class OrangeHelper
{
public:
    enum VenusType
    {
        VN_None = 0x00, 
        VN_Face = 0x01,   
        VN_Gesture = 0x02,  
        VN_BodySegment = 0x04, 
        VN_All = 0xFF     
    };
    
    enum EffectType
    {
        ET_BasicBeauty,
        ET_BasicBeautyType,
        ET_SeniorBeautyType,
        ET_FilterHoliday,
        ET_FilterClear,
        ET_FilterWarm,
        ET_FilterFresh,
        ET_FilterTender,
    };
    
    enum EffectParamType {
        EP_BasicBeautyIntensity,
        EP_BasicBeautyOpacity,      
        EP_FilterHolidayIntensity,  
        EP_FilterClearIntensity,    
        EP_FilterWarmIntensity,     
        EP_FilterFreshIntensity,    
        EP_FilterTenderIntensity,   
        EP_BasicTypeIntensity,      
        EP_SeniorTypeThinFaceIntensity,       
        EP_SeniorTypeSmallFaceIntensity,      
        EP_SeniorTypeSquashedFaceIntensity,   
        EP_SeniorTypeForeheadLiftingIntensity,
        EP_SeniorTypeWideForeheadIntensity,   
        EP_SeniorTypeBigSmallEyeIntensity,    
        EP_SeniorTypeEyesOffsetIntensity,              
        EP_SeniorTypeEyesRotationIntensity,   
        EP_SeniorTypeThinNoseIntensity,       
        EP_SeniorTypeLongNoseIntensity,       
        EP_SeniorTypeThinNoseBridgeIntensity, 
        EP_SeniorTypeThinmouthIntensity,      
        EP_SeniorTypeMovemouthIntensity,      
        EP_SeniorTypeChinLiftingIntensity,    
    };

	enum LogLevel {
		LG_Info = 0x01,
		LG_Warn = 0x02,
		LG_Error = 0x04,
		LG_Debug = 0x08,
		LG_Verbose = 0xFF,
	};
    
    struct EffectParam
    {
        int curVal;
        int maxVal;
        int minVal;
        int defVal;
    };
    
    struct GLTexture
    {
        int textureId; //OpenGL texture id
        int width;  //OpenGL texture width.
        int height; //OpenGL texture height.
        int format; //OpenGL texture format, e.g. GL_RGBA.
        int target; //OpenGL texture target, e.g. GL_TEXTURE_2D.
    };
    
    struct ImageInfo
    {
        int deviceType;
        int facePointDir;
        unsigned char* data;
        int dir;
        int orientation;
        int width;
        int height;
        int format;
        bool frontCamera;
        float timestamp;
    };

public:
    bool createContext(
           const std::string& serialNumber,
           const std::string& licensePath,
           const std::string& resDir,
           VenusType aiType = VN_All);

    void destroyContext();
    
    bool isContextValid();
    
    bool enableEffect(EffectType effectType, bool enabled);
    
    bool releaseEffect(EffectType effectType);
    
    bool enableSticker(const std::string& path, bool enabled);
    
    bool releaseSticker(const std::string& path);

    bool enableGesture(const std::string& path, bool enabled);
    
    bool releaseGesture(const std::string& path);
    
    int getEffectParam(EffectParamType paramType);
    
    bool getEffectParamDetail(EffectParamType paramType, EffectParam& paramVal);
    
    bool setEffectParam(EffectParamType paramType, int value);
    
    bool updateFrameParams(const GLTexture& textureIn, const GLTexture& textureOut, const ImageInfo& image);

    bool checkStickerResult(const std::vector<std::string>& paths, std::vector<int>& results);

	bool setLogLevel(int level);

	bool setLogCallback(void(*callback)(const char* msg));

private:
    struct EffectInfo
    {
        std::string path;
        int effectId;
        bool enabled;
        int result;
        EffectInfo() : effectId(0), enabled(false) {}
        EffectInfo(const std::string& p, int i, bool e) : path(p), effectId(i), enabled(e), result(0) {}
    };
    
    int getEffectId(EffectParamType ep);
    int getFilterId(EffectParamType ep);
    std::string getParamName(EffectParamType ep);
    
    OFHandle _context;
    std::string _resDir;
    std::vector<EffectInfo> _effects;
    EffectInfo _sticker;
    OF_Texture _inTex;
    OF_Texture _outTex;
    OF_FrameData _frameData;
};
