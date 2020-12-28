@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET BASE_URL=https://docker.lvh.me/api/v1/
SET CURL_ARGS=-s -f -S --cacert "%~dp0\..\ldap_data\ca.crt"

REM SET PATH=C:\msys64\mingw64\bin;%PATH%

ECHO %BASE_URL%
curl %CURL_ARGS% -X GET -i "%BASE_URL%" > "%TMP%\curl.api.home.txt"
IF %ErrorLevel% NEQ 0 EXIT /B

ECHO %BASE_URL%auth/login
REM curl %CURL_ARGS% -X POST -i "%BASE_URL%auth/login" -H "Content-Type: application/json" -d "{""username"":""ssl"",""password"":""1234""}"

curl %CURL_ARGS% -X POST -i "%BASE_URL%auth/login_ssl" --cert "%~dp0\client.crt" --key "%~dp0\client.key" > "%TMP%\curl.api.token.txt"
IF %ErrorLevel% NEQ 0 EXIT /B

FOR /F tokens^=4^ delims^=^" %%G IN ('TYPE "%TMP%\curl.api.token.txt" ^| FIND """jwt"":"') DO SET JWT=%%G
IF "%JWT%" == "" (
  ECHO Cannot retrieve JWT
  EXIT /B -1
)

REM curl %CURL_ARGS% -X GET -i "%BASE_URL%auth/token" -H "Authorization: Bearer %JWT%"

ECHO %BASE_URL%upload
curl %CURL_ARGS% -X POST -i "%BASE_URL%upload" -H "Authorization: Bearer %JWT%" -H "Upload-Length: 22610944" -H "Upload-Metadata: name L3dpbi9tc2h0bWwuZGxs, last_modified MTU2MDM5NzcxMjAxNw" -H "Content-Type: application/offset+octet-stream" --data-binary "@%SystemRoot%\System32\mshtml.dll" > "%TMP%\curl.api.upload.txt"
IF %ErrorLevel% NEQ 0 EXIT /B

ECHO %BASE_URL%file/1/download?token=%JWT%
curl %CURL_ARGS% -X HEAD -I "%BASE_URL%file/1/download?token=%JWT%"
IF %ErrorLevel% NEQ 0 EXIT /B

ENDLOCAL
