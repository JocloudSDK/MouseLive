
#ifndef  PB_UTILSRAPIDJSON
#define PB_UTILSRAPIDJSON

#include <iostream>
#include <vector>
#include <list>
#include <functional>
#include <algorithm>
#include "rapidjson/document.h"
#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

#define RapidjsonWriteBegin(writer) {writer.StartObject();
#define RapidjsonWriteEnd()   writer.EndObject();}

#define RapidjsonWriteString(XXX) writer.Key(#XXX);writer.String(XXX.data());
#define RapidjsonWriteChar(XXX) writer.Key(#XXX);writer.String(XXX,strlen(XXX));
#define RapidjsonWriteInt(XXX) writer.Key(#XXX);writer.Int(XXX);
#define RapidjsonWriteInt64(XXX) writer.Key(#XXX);writer.Int64(XXX);
#define RapidjsonWriteUInt(XXX) writer.Key(#XXX);writer.UInt(XXX);
#define RapidjsonWriteUint64(XXX) writer.Key(#XXX);writer.Uint64(XXX);
#define RapidjsonWriteDouble(XXX) writer.Key(#XXX);writer.Double(XXX);
#define RapidjsonWriteClass(XXX) writer.Key(#XXX);((JsonBase*)(&XXX))->ToWrite(writer);	

#define RapidjsonParseBegin(val) for (Value::ConstMemberIterator itr = val.MemberBegin(); itr != val.MemberEnd(); ++itr){
#define RapidjsonParseEnd()  }
#define RapidjsonParseToString(XXX) \
	if (strcmp(itr->name.GetString(), #XXX) == 0) { \
		if (itr->value.IsString()) \
			XXX = itr->value.GetString(); \
	}

#define RapidjsonParseToInt(XXX) if (strcmp(itr->name.GetString(), #XXX) == 0)XXX = itr->value.GetInt();
#define RapidjsonParseToBool(XXX) if (strcmp(itr->name.GetString(), #XXX) == 0)XXX = itr->value.GetBool();
#define RapidjsonParseToInt64(XXX) if (strcmp(itr->name.GetString(), #XXX) == 0)XXX = itr->value.GetInt64();
#define RapidjsonParseToUInt(XXX)  if (strcmp(itr->name.GetString(), #XXX) == 0)XXX = itr->value.GetUint();
#define RapidjsonParseToUint64(XXX) if (strcmp(itr->name.GetString(), #XXX) == 0)XXX = itr->value.GetUint64();
#define RapidjsonParseToDouble(XXX) if (strcmp(itr->name.GetString(),#XXX) == 0)XXX = itr->value.GetDouble();
#define RapidjsonParseToClass(XXX) \
if (strcmp(itr->name.GetString(), #XXX) == 0) \
	if (!itr->value.IsNull()) \
		((JsonBase*)(&XXX))->ParseJson(itr->value);

#define RapidjsonParseToChar(XXX)if (strcmp(itr->name.GetString(), #XXX) == 0)\
{\
	int size = ARRAY_SIZE(XXX);\
	const char *s = itr->value.GetString();\
	int len = strlen(s);\
	strncpy(XXX, s, std::min(size, len));\
}\

namespace PBLIB
{
	namespace RapidJsonHelper
	{
		using namespace rapidjson;

		class JsonBase
		{
		public:

			JsonBase(){}
			~JsonBase(){}

			std::string ToJson();
			static void FromJson(JsonBase *p, const std::string &json);

		protected:

			template<typename T>
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, T &val){
				JsonBase *p = &val;
				p->ToWrite(writer);
			}
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, int32_t &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, int64_t &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, uint32_t &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, uint64_t &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, double &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, bool &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, std::string &val);
			static	void ToWriteEvery(Writer<StringBuffer>  &writer, char * val);

			template<typename T>
			static	void ToParseEvery(const Value &val, T &t)
			{
				JsonBase *p = &t;
				p->ParseJson(val);
			}

			static	void ToParseEvery(const Value &val, int32_t &t);
			static	void ToParseEvery(const Value &val, int64_t &t);
			static	void ToParseEvery(const Value &val, uint32_t &t);
			static	void ToParseEvery(const Value &val, uint64_t &t);
			static	void ToParseEvery(const Value &val, double &t);
			static	void ToParseEvery(const Value &val, bool &t);
			static	void ToParseEvery(const Value &val, std::string &t);
			static	void ToParseEvery(const Value &val, char t[]);

		public:
			virtual void ToWrite(Writer<StringBuffer>  &writer);
			virtual void ParseJson(const Value& val);
		};

		template<typename T>
		class JsonArray :public JsonBase
		{
		public:

			std::list<T> arr;
			JsonArray(){}
			~JsonArray(){}

		public:
			virtual void ToWrite(Writer<StringBuffer>  &writer)
			{
				writer.StartArray();
				for each (T ent in arr)
				{
					ToWriteEvery(writer, ent);
				}
				writer.EndArray();
			}

			virtual void ParseJson(const Value& val)
			{
				SizeType len = val.Size();
				for (size_t i = 0; i < len; i++)
				{
					const Value &f = val[i];
					T t;
					ToParseEvery(f, t);
					arr.push_back(t);
				}
			}
		};
	}
}

#endif