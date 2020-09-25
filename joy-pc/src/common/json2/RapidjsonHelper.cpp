#include "RapidjsonHelper.h"

namespace PBLIB
{
	namespace RapidJsonHelper
	{
		using namespace rapidjson;

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, int32_t &val) {
			writer.Int(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, int64_t &val) {
			writer.Int64(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, uint32_t &val) {
			writer.Uint(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, uint64_t &val) {
			writer.Uint64(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, double &val) {
			writer.Double(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, bool &val) {
			writer.Bool(val);
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, std::string &val) {
			writer.String(val.data());
		}

		void JsonBase::ToWriteEvery(Writer<StringBuffer>  &writer, char * val) {
			writer.String(val, strlen(val));
		}

		void JsonBase::ToParseEvery(const Value &val, int32_t &t) {
			t = val.GetInt();
		}

		void JsonBase::ToParseEvery(const Value &val, int64_t &t) {
			t = val.GetInt64();
		}

		void JsonBase::ToParseEvery(const Value &val, uint32_t &t) {
			t = val.GetUint();
		}

		void JsonBase::ToParseEvery(const Value &val, uint64_t &t) {
			t = val.GetUint64();
		}

		void JsonBase::ToParseEvery(const Value &val, double &t) {
			t = val.GetDouble();
		}

		void JsonBase::ToParseEvery(const Value &val, bool &t) {
			t = val.GetBool();
		}

		void JsonBase::ToParseEvery(const Value &val, std::string &t) {
			t = val.GetString();
		}

		void JsonBase::ToParseEvery(const Value &val, char t[]) {
			int size = ARRAY_SIZE(t);
			const char *s = val.GetString();
			int len = strlen(s);
			strncpy(t, s, std::min(size, len));
		}

		std::string JsonBase::ToJson(){
			StringBuffer s;
			Writer<StringBuffer> writer(s);
			this->ToWrite(writer);
			return s.GetString();
		}

		void JsonBase::FromJson(JsonBase *p, const std::string &json) {
			Document document;
			document.Parse(json.data());
			const Value &val = document;
			p->ParseJson(val);
		}

		void	JsonBase::ToWrite(Writer<StringBuffer>  &writer) {
		}

		void JsonBase::ParseJson(const Value& val) {
		}
	}
}