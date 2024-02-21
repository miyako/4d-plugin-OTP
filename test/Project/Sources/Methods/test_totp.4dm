//%attributes = {}
var $params : Object

$params:={secret: "😣."; \
type: OTP Type totp; \
algorithm: OTP Algorithm SHA1; \
t0: 0; \
timestamp: 1708522781; \
period: 30; \
digits: 6; \
issuer: "github"; \
account: "keisuke.miyako@4d.com"}

$status:=OTP Generate($params)

ASSERT:C1129($status.base32_secret="6CPZRIZO")
ASSERT:C1129($status.otp="219145")
ASSERT:C1129($status.url="otpauth://totp/github%3Akeisuke.miyako%404d.com?issuer=github&secret=6CPZRIZO&algorithm=SHA1&digits=6&period=30")

SET PICTURE TO PASTEBOARD:C521($status.qr)