# 4d-plugin-OTP
OTP.

**hotp** code based on [archiecobbs/mod-authn-otp](https://github.com/archiecobbs/mod-authn-otp/tree/master)

# Example

```4d
$params:={secret: "😣."; \
type: OTP Type hotp; \
algorithm: OTP Algorithm SHA1; \
counter: 1; \
digits: 6}

$status:=OTP Generate($params)

ASSERT($status.base32_secret="6CPZRIZO")
ASSERT($status.otp="912647")
```

|key|type||
|:-:|:-:|:-|
|secret|Text|if passed, internally encoded to base32_secret|
|base32_secret|Text||
|type|Text|totp(default), hotp|
|algorithm|Text|SHA1(default), SHA256, SHA512|
|digits|Integer|6(default)|
|period|Integer|30(default), totp only|
|t0|Integer|0(default), totp only|
|timestamp|Integer|default=now, totp only|
|counter|Integer|0(default), hotp only|

* QR code options

|key|type||
|:-:|:-:|:-|
|format|Text|.png(default), .svg|
|size|Integer|3(default)|
|dpi|Integer|72(default)|
|margin|Integer|0(default)|
|version|Integer|1(default)|
|level|Integer|0=L(default), 1=M, 2=Q, 3=H|

# Acknowledgements

* [BASE32](https://github.com/mjg59/tpmtotp/blob/master/base32.h) by Adrien Kunysz
* RFC3986 by [dnmfarrell/URI-Encode-C](https://github.com/dnmfarrell/URI-Encode-C) 
