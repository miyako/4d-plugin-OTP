# 4d-plugin-OTP
OTP.

# Example

```4d
var $params : Object

$params:={secret: "😣."}

$status:=OTP Generate($params)

$params.type:="hotp"

$status:=OTP Generate($params)
```

|key|type||
|:-:|:-:|:-|
|secret|Text||
|type|Text|totp(default), hotp|
|algorithm|Text|SHA1(default), SHA256, SHA512|
|digits|Integer|6(default), 8|
|period|Integer|30(default), totp only|
|counter|Integer|0(default), hotp only|

# Acknowledgements

* [BASE32](https://github.com/mjg59/tpmtotp/blob/master/base32.h) by Adrien Kunysz
