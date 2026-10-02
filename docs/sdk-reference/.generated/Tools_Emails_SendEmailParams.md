**`SendEmailParams`** — `WebCon.WorkFlow.SDK.Tools.Emails`

Class representing arguments that user passes to SendEmail method

- `AttachmentsMode AttachmentMode` *(property)* — DoNotSend to not include attachments at all (default option), SendAll to include all attachments, SQLQuery to specify attachments to include by SQL query
- `Boolean BypassEmailQueue` *(property)* — True, when e-mail should be sent immediately (by default e-mail is beeing put into queue and when action fails it won't be sent); otherwise, false
- `Boolean DefaultTemplateIncludeValues` *(property)* — True, when values of attributes and item's lists should be included; otherwise, false
- `String FromAddress` *(property)* — Sender address.
- `String MessageText` *(property)* — Content of message, when empty - standard template will be used.
- `String SqlAttachmentsQuery` *(property)* — Optional paramether used when SQLQuery attachment mode is selected.
- `String Subject` *(property)* — Subject of message
- `List<String> ToAddresses` *(property)* — List of receivers
- `List<String> ToBCCAddresses` *(property)* — Hidden message recievers.
- `IEnumerable<BpsAccount> ToBCCBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve hidden copy of this message.
- `IEnumerable<BpsAccount> ToBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve this message.
- `List<String> ToCCAddresses` *(property)* — List of people who will recieve copy of message.
- `IEnumerable<BpsAccount> ToCCBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve copy of this message.
- `Boolean UseDefaultTemplate` *(property)* — True, when standard template should be used; otherwise, false
