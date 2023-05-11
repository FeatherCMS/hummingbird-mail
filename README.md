# Hummingbird Mail Component

A [Hummingbird](https://github.com/hummingbird-project/hummingbird) mail component, which can send emails using via [AWS SES](https://aws.amazon.com/ses/) or [SMTP](https://hu.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) providers.

## Getting started 

Adding the dependency

Add the following entry in your Package.swift to start using HummingbirdAWS:

```swift
.package(url: "https://github.com/feathercms/hummingbird-mail", from: "1.0.0"),
```

and HummingbirdMail dependency to your target:

```swift
.product(name: "HummingbirdMail", package: "hummingbird-mail"),
```

Mail provider services

```swift
.product(name: "HummingbirdSMTPMail", package: "hummingbird-mail"),
.product(name: "HummingbirdSESMail", package: "hummingbird-mail"),
```    

## HummingbirdSES

Simple usage

```swift
import Hummingbird
import HummingbirdMail
import HummingbirdSESMail

let env = ProcessInfo.processInfo.environment
let logger = Logger(label: "aws-logger")

let app = HBApplication()
app.services.aws = .init(
    credentialProvider: .static(
        accessKeyId: env["SES_ID"]!,
        secretAccessKey: env["SES_SECRET"]!
    ),
    httpClientProvider: .createNewWithEventLoopGroup(
        app.eventLoopGroup
    ),
    logger: logger
)

app.services.setUpSESMailer(
    using: app.aws,
    region: env["SES_REGION"]!
)

let email = try HBMail(
    from: HBMailAddress(env["MAIL_FROM]!),
    to: [
        HBMailAddress(env["MAIL_TO]!),
    ],
    subject: "test ses with simple text",
    body: "This is a simple text email body with SES."
)

try await app.mailer.send(email)
```

## SMTP

Simple usage

```swift
import Hummingbird
import HummingbirdMail
import HummingbirdSMTPMail

let env = ProcessInfo.processInfo.environment

let app = HBApplication()
app.services.setUpSMTPMailer(
    eventLoopGroup: app.eventLoopGroup,
    hostname: env["SMTP_HOST"]!,
    signInMethod: .credentials(
        username: env["SMTP_USER"]!,
        password: env["SMTP_PASS"]!
    )
)

let email = try HBMail(
    from: HBMailAddress(env["MAIL_FROM]!),
    to: [
        HBMailAddress(env["MAIL_TO]!),
    ],
    subject: "test ses with simple text",
    body: "This is a simple text email body with SES."
)

try await app.mailer.send(email)
```

## Credits 

The NIOSMTP library is heavily inspired by [Mikroservices/Smtp](https://github.com/Mikroservices/Smtp).
