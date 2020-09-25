/*
 * File: string
 * Author: LanPZzzz
 * Date: 2020/06/02
 * Description: string convert
 */
#pragma once

#include <string>
#include <QString>
#include <QWidget>

std::string ws2s(const std::wstring &ws);
std::wstring s2ws(const std::string &s);
std::string stringFormat(const char *pszFmt, ...);
QString stdString2QString(const std::string& str);
std::string qstring2stdString(const QString& qs);
int getStringWidth(QString& msg, QWidget& widget);