#ifndef HMR_TEXT_H
#define HMR_TEXT_H

#include <Hummer/MessageService.h>

extern "C" {
	
	// 文本消息内容创建的工厂方法，HMRMessage中承载的content
	// 创建HMRMessage时，需通过此工厂方法，传入文本内容，此方法会添加必要的内部解析字段，构建出合适的文本消息内容
	// @param utf8Text 发送的文本内容，因涉及多端通信适配，如PC与移动端，为确保编解码正确，需传入utf-8编码的字符串
	// @param bytesCount utf8Text的文本size
	// @discuss 文本消息内容的构造和解析，相对于HMRExtractTextFromContent解析content
	HMR_API HMRMessageContent HMRMakeText(const char *utf8Text, uint16_t bytesCount);

	// 文本消息内容解析的工厂方法
	// 解析HMRMessage时，需通过此工厂方法，处理content中的内部字段，并保证解码方式，构建出正确的文本消息内容
	// @param utf8Text 业务层获取的最终文本内容
	// @param outSize 获取文本相对应的长度
	// @discuss 文本消息内容的构造和解析，相对于HMRMakeTextContent构造content
	HMR_API uint32_t HMRExtractText(HMRMessageContent content, char utf8Text[HMRMessageContentSize], uint16_t *outSize);

	// 文本消息内容动态判别。除非是业务自身拓展的类型，否则应避免直接手工解析和构造
	HMR_API uint32_t HMRIsText(HMRMessageContent content);

}

#endif // HMR_TEXT_H
