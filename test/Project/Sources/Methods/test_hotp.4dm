//%attributes = {}
var $params : Object

$params:={secret: "😣."; \
type: OTP Type hotp; \
algorithm: OTP Algorithm SHA1; \
counter: 1; \
digits: 6}

$status:=OTP Generate($params)

ASSERT:C1129($status.base32_secret="6CPZRIZO")
ASSERT:C1129($status.otp="912647")

/*
hotp
https://asecuritysite.com/hash/hotp
*/