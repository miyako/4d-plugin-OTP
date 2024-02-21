//%attributes = {}
var $params : Object

$params:={secret: "😣."; \
type: OTP Type hotp; \
algorithm: OTP Algorithm SHA1; \
counter: 1; \
digits: 6; \
issuer: "github"; \
account: "keisuke.miyako@4d.com"}

$status:=OTP Generate($params)

ASSERT:C1129($status.base32_secret="6CPZRIZO")
ASSERT:C1129($status.otp="912647")
ASSERT:C1129($status.url="otpauth://hotp/github%3Akeisuke.miyako%404d.com?issuer=github&secret=6CPZRIZO&algorithm=SHA1&digits=6&counter=0")

SET PICTURE TO PASTEBOARD:C521($status.qr)