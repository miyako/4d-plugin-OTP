![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-OTP)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-OTP/total)

# 4d-plugin-OTP

A 4D plugin that generates HOTP (RFC 4226) and TOTP (RFC 6238) one-time passcodes and can render the matching `otpauth://` provisioning URL as a QR code `Picture` (PNG or SVG). Random-byte generation for secrets is exposed separately via a CSPRNG (OpenSSL `RAND_bytes`).

| Command | Returns | Purpose |
|---|---|---|
| [OTP Generate](#otp-generate) | Object | Compute a HOTP/TOTP code, its `otpauth://` URL, and (optionally) a QR code `Picture` |
| [OTP Random](#otp-random) | Text | Generate a cryptographically random, Base32-encoded value (e.g. for use as a secret) |

**Platforms:** macOS, Windows (4D has no Linux runtime; there is no divergent per-platform behavior in this plugin's own code beyond one Windows-only `stdio` build fix that has no effect on command behavior).

---

## Requirements & platform notes

- Both commands are **thread-safe** (per `manifest.json`).
- `OTP Generate`'s single parameter is a **mandatory** object. Nothing in the source guards against a missing/undefined object parameter — every sample method supplies it, and none demonstrate calling `OTP Generate` with zero arguments, so treat it as required.
- `OTP Random`'s single parameter is **optional** — confirmed by the plugin's own test file, which calls it both with and without an argument (`OTP Random()` and `OTP Random(100)`).
- **Unrecognized values for `type` and `algorithm` fail silently, not with a 4D error.** If `type` isn't exactly `"hotp"`, the command falls back to `"totp"`; if `algorithm` isn't exactly `"SHA256"` or `"SHA512"`, it falls back to `"SHA1"`. A typo won't raise an error — it'll quietly produce a code for the default type/algorithm instead. Check `$status.type` / `$status.algorithm` in the returned object if you need to confirm what was actually used.
- **`qr` is only present in the result if the QR code actually fit.** If the encoded `otpauth://` URL is too long for the requested `version` (QR symbol version, 1–40) at the requested `level`, `qr` is silently omitted from the result — there's no error, and no partial/placeholder picture. This is most likely to bite when `issuer` and `account` are both long strings, pushing the encoded URL past what a low `version` can hold.
- **`OTP Type <x>` / `OTP Algorithm <x>` constants used in this plugin's own samples** (`OTP Type hotp`, `OTP Type totp`, `OTP Algorithm SHA1`, `OTP Algorithm SHA256`, `OTP Algorithm SHA512`) aren't declared in the `manifest.json` excerpt available for this review, so their exact declared values couldn't be independently verified here. What's verified directly from the C++ source is the literal text each one must resolve to: `"hotp"` / `"totp"` / `"SHA1"` / `"SHA256"` / `"SHA512"` — passing those literal strings works regardless of the constants.
- **This reference describes the plugin's source as patched during code review** (bounds added to `digits`, `version`, `size`, `dpi`, `margin`; a hang fixed in `OTP Random`'s failure path; an empty-secret guard added). These behaviors are true of the corrected source — confirm your built plugin binary actually includes them before relying on the documented bounds below.

---

## OTP Generate

### Syntax
```4d
OTP Generate(options) -> Result
```

| Parameter | Type | Description |
|---|---|---|
| `options` | Object | OTP configuration — see **Options object** below. Mandatory. |
| Result | Object | Computed OTP and metadata — see **Result object** below. |

#### Options object

| Property | Type | Description |
|---|---|---|
| `secret` | Text | Raw (non-Base32) shared secret. If present, it takes priority over `base32_secret` and is Base32-encoded internally before use. |
| `base32_secret` | Text | An already Base32-encoded secret, used as-is. Only read if `secret` is absent. |
| `type` | Text | `"hotp"` or `"totp"`. Anything else (including omitted) falls back to `"totp"`. |
| `algorithm` | Text | `"SHA1"` (default), `"SHA256"`, or `"SHA512"`. Anything else falls back to `"SHA1"`. |
| `digits` | Integer | Number of digits in the generated code. Default `6`. Must be between `1` and `10` inclusive — out-of-range values are ignored and the current/default value is kept. |
| `period` | Integer | TOTP time-step, in seconds. Default `30`. Only used when `type` is `"totp"`. Values `<= 0` are ignored. |
| `t0` | Integer | TOTP start epoch (Unix time). Default `0`. Only used when `type` is `"totp"`. |
| `timestamp` | Integer | Unix timestamp to compute the TOTP counter from. Defaults to the current server time. Only used when `type` is `"totp"`. |
| `counter` | Integer (64-bit) | HOTP counter value. Default `0`. Only used when `type` is `"hotp"`. |
| `account` | Text | Account label (e.g. an email address), used to build `label` and the `otpauth://` URL. |
| `issuer` | Text | Issuer/service name. Combined with `account` as `issuer:account` for `label` if both are present. |
| `format` | Text | `.svg` for an SVG-rendered QR code; anything else (including omitted) renders PNG. |
| `version` | Integer | QR code symbol version, `1`–`40`. Default `1`. Out-of-range values are ignored. |
| `size` | Integer | Pixels per QR module, `1`–`100`. Default `3`. Out-of-range values are ignored. |
| `margin` | Integer | Quiet-zone margin, in modules, `0`–`100`. Default `0`. Out-of-range values are ignored. |
| `dpi` | Integer | Resolution metadata embedded in the PNG output, `1`–`2400`. Default `72`. Ignored for SVG output. Out-of-range values are ignored. |
| `level` | Integer | QR error-correction level. Default is the lowest level (`L`). Native `qrencode` levels are typically `0`–`3` (`L`/`M`/`Q`/`H`) — check your vendored `qrcode.h` for the exact enum values, which weren't available in this review. |

#### Result object

| Property | Type | Description |
|---|---|---|
| `base32_secret` | Text | The Base32 secret actually used (empty if neither `secret` nor `base32_secret` was supplied — see Error handling below). |
| `account` | Text | Echoed back only if `account` was supplied. |
| `issuer` | Text | Echoed back only if `issuer` was supplied. |
| `type` | Text | `"hotp"` or `"totp"` — whichever was actually used. |
| `algorithm` | Text | `"SHA1"`, `"SHA256"`, or `"SHA512"` — whichever was actually used. |
| `digits` | Integer | The digit count actually used. |
| `period` | Integer | Present only if `type` is `"totp"`. |
| `t0` | Integer | Present only if `type` is `"totp"`. |
| `timestamp` | Integer | Present only if `type` is `"totp"`. The timestamp actually used (server time if not supplied). |
| `counter` | Integer (64-bit) | Present only if `type` is `"hotp"`. The counter actually used. |
| `otp` | Text | The generated one-time passcode, zero-padded to `digits` characters. |
| `label` | Text | Present only if `account` and/or `issuer` produced a label (see Description). |
| `url` | Text | The full `otpauth://` provisioning URL. |
| `qr` | Picture | The QR code rendering of `url`, as PNG or SVG per `format`. **Omitted entirely** if the URL didn't fit the requested `version`/`level` (see Requirements & platform notes). |

### Description

`secret` and `base32_secret` are mutually exclusive — if both are present, `secret` wins and `base32_secret` is ignored. If neither is present, the command still runs and returns an all-zero code (see Error handling).

`label` is only populated in the result if `account` was supplied: it's set to `account` alone, or to `issuer:account` if both `issuer` and `account` were supplied. Supplying `issuer` alone, with no `account`, does **not** populate `label` — the code doesn't fall back to issuer-only.

For `type: "totp"`, the counter used internally is `(timestamp - t0) / period`. For `type: "hotp"`, the counter is used directly as supplied (or `0` if omitted).

### Example

From the plugin's own test method (`test_totp.4dm`):
```4d
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
```

From the plugin's own test method (`test_hotp.4dm`), the HOTP form:
```4d
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
ASSERT:C1129($status.url="otpauth://hotp/github%3Akeisuke.miyako%404d.com?issuer=github&secret=6CPZRIZO&algorithm=SHA1&digits=6&counter=1")

SET PICTURE TO PASTEBOARD:C521($status.qr)
```

A minimal call supplying an already-Base32 secret directly, requesting an SVG QR code:
```4d
var $params; $status : Object

$params:=New object("base32_secret"; "JDDK4U6G3BJLEZ7Y"; \
"type"; "totp"; \
"digits"; 6; \
"format"; ".svg")

$status:=OTP Generate($params)

// $status.otp holds the current TOTP code
// $status.qr holds an SVG-rendered QR code Picture
```

---

## OTP Random

### Syntax
```4d
OTP Random(length) -> Result
```

| Parameter | Type | Description |
|---|---|---|
| `length` | Integer | Number of random bytes to generate, before Base32 encoding. Optional — defaults to `20` if omitted or `<= 0`. Clamped to a maximum of `4096`. |
| Result | Text | The random bytes, Base32-encoded. |

### Description

Bytes come from OpenSSL's `RAND_bytes` (a CSPRNG), suitable for generating a new HOTP/TOTP secret. The result is Base32-encoded text, ready to pass straight into `OTP Generate` as `base32_secret`.

If the underlying CSPRNG call itself fails (rare — typically only under serious system-entropy or OpenSSL-configuration problems), the command returns an empty string rather than raising a 4D error. Check for an empty result if you need to detect that case.

### Example

From the plugin's own test method (`test_rand.4dm`):
```4d
$random:=OTP Random()  //default length=20
$random:=OTP Random(100)
```

Generating a secret and feeding it straight into `OTP Generate`:
```4d
var $secret; $params; $status : Object
var $secret_text : Text

$secret_text:=OTP Random(20)

$params:=New object("base32_secret"; $secret_text; "type"; "totp"; "digits"; 6)
$status:=OTP Generate($params)

// $status.otp is a fresh TOTP code for the newly generated secret
```

---

## Error handling & troubleshooting

- **No `secret` or `base32_secret` supplied.** The command does not raise an error — it returns `base32_secret: ""` and `otp` as a string of `digits` zeros (e.g. `"000000"`). Check `$status.base32_secret` for emptiness if you need to detect a missing secret.
- **`type` or `algorithm` typos fail silently.** An unrecognized `type` behaves as `"totp"`; an unrecognized `algorithm` behaves as `"SHA1"`. There is no error and no field indicating "unrecognized value used" — inspect `$status.type`/`$status.algorithm` if this matters to your code.
- **`qr` can be missing from the result with no error.** This happens when the encoded `otpauth://` URL is too long to fit the chosen `version`/`level`. If you always need a QR image, check for the property's presence and raise `version` (up to `40`) if it's absent.
- **`issuer` without `account` produces no `label`.** If you want a label in the URL/QR, supply `account` (with or without `issuer`) — `issuer` alone is not enough.
- **Numeric option bounds are enforced, not clamped-with-feedback.** Out-of-range values for `digits`, `version`, `size`, `margin`, and `dpi` are silently ignored (the previous/default value is kept) rather than clamped to the nearest valid bound or reported as an error.
- **`OTP Random` returning an empty string means the CSPRNG call failed**, not that zero-length randomness was requested — `length <= 0` is redefined to the default of `20`, so an empty result only ever means failure, never "you asked for nothing."
- **Externally-supplied `base32_secret` values may not match other authenticator apps.** This plugin's own test files (`test_totp1.4dm`, `test_totp_google.4dm`) record exactly this: the same `base32_secret`/`timestamp`/`period` combination produces a code that does **not** match Google Authenticator for a directly-supplied `base32_secret` (the sample notes the plugin's own output as ❌ against the ✅ correct value). The counter construction, HMAC extraction, and truncation arithmetic in the plugin's C++ all match the standard HOTP/TOTP algorithm as reviewed; the discrepancy could not be traced further without the `base32.c`/`.h` decoder source, which wasn't available for this review. If cross-app interoperability matters, verify against a real authenticator app before depending on a directly-supplied `base32_secret` — the round-trip `secret` → internal Base32 encode → decode path (used when you pass `secret` instead) has matching self-consistent test coverage and is not implicated by this specific caveat.

---

## Quick reference

```4d
// Generate a new random Base32 secret
var $secret : Text
$secret:=OTP Random(20)

// TOTP, default 30s period, current time
var $params; $status : Object
$params:=New object("base32_secret"; $secret; "type"; "totp"; "digits"; 6; "issuer"; "Acme"; "account"; "jane@acme.com")
$status:=OTP Generate($params)
SET PICTURE TO PASTEBOARD:C521($status.qr)

// HOTP with an explicit counter
$params:=New object("base32_secret"; $secret; "type"; "hotp"; "counter"; 1; "digits"; 6)
$status:=OTP Generate($params)

// SVG QR instead of PNG
$params:=New object("base32_secret"; $secret; "type"; "totp"; "format"; ".svg"; "version"; 4)
$status:=OTP Generate($params)
```
