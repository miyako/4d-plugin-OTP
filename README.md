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
|secret|Text||
|type|Text|totp(default), hotp|
|algorithm|Text|SHA1(default), SHA256, SHA512|
|digits|Integer|6(default), 8|
|period|Integer|30(default), totp only|
|counter|Integer|0(default), hotp only|

# Acknowledgements

* [BASE32](https://github.com/mjg59/tpmtotp/blob/master/base32.h) by Adrien Kunysz
