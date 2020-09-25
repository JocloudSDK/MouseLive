#ifndef HMR_CONTENT_TEXT_H
#define HMR_CONTENT_TEXT_H

#include <Hummer/MessageService.h>

extern "C" {

	// 广播信令消息内容创建的工厂方法，HMRMessage中承载的content
	// 创建HMRMessage时，需通过此工厂方法，传入文本内容，此方法会添加必要的内部解析字段，构建出正确的广播信令消息内容
	// @param signal 发送的文本内容，因涉及多端通信适配，如PC与移动端，为确保编解码正确，需传入utf-8编码的字符串
	// @param bytesCount utf8Text的文本size
	// @discuss 此类消息内容可在频道内进行广播，相对于HMRExtractSignalFromContent解析content
	HMR_API HMRMessageContent HMRMakeSignal(const char *signal, uint16_t bytesCount);

	// 广播信令消息内容解析的工厂方法，解析HMRMessage时，需通过此工厂方法，处理content中的内部字段，并保证解码方式，构建出正确的广播信令消息内容
	// @param signal 业务层获取的最终信令内容
	// @param outSize 获取信令内容相对应的长度
	// @discuss 消息内容的构造和解析，相对于HMRMakeSignalContent构造content
	HMR_API uint32_t HMRExtractSignal(HMRMessageContent content, char signal[HMRMessageContentSize], uint16_t *outSize);

	// 广播信令消息内容动态判别。除非是业务自身拓展的类型，否则应避免直接手工解析和构造
	HMR_API uint32_t HMRIsSignal(HMRMessageContent content);

}

#endif // HMR_CONTENT_SIGNAL_H
