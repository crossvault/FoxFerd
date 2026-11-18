# FoxFerd

FoxFerd is a Visual FoxPro class library that creates invoice XML from your application data.
It calculates totals, checks business rules and validates the XML structure before saving.
It does not read incoming invoices or send files to recipients.

## Formats

CII and UBL are two XML syntaxes for the European invoice data model EN 16931.
FoxFerd currently writes CII only. A profile selects the permitted fields and rules.

| `cProfil` | Output |
|---|---|
| `EN16931` | CII XML for the EN 16931 profile of ZUGFeRD / Factur-X |
| `XRECHNUNG-CII` | CII XML with the additional German XRechnung rules |
| `EXTENDED` | CII XML with additional Factur-X fields and groups |

The fixed versions are ZUGFeRD 2.5.2 / Factur-X 1.09.2 and XRechnung 3.0.2.
BASIC, UBL and the XRechnung extension are not implemented.
Agree on the format and delivery channel with your recipient.

## Requirements

- Windows with VFP 9 or VFPA 10.2.
- The matching `foxferd.vcx` and `foxferd.vct` files.
- MSXML 6 as a 32-bit COM component.
- Your own schema downloads and the unit code list, prepared under `xsd`.
- An existing, writable output directory.

An XSD schema describes the XML structure. Business rules check relationships between fields.
The library does not require Java or an external validator at runtime.
Its method code uses the VFP 6 language subset; loading the VFP 9 binary in VFP 6 is unverified.

## First invoice

From a fresh clone, follow the [schema preparation instructions](EINBAU.md#schemas-vorbereiten).
They use your own FeRD English ZIP and the CII D16B schemas from the KoSIT configuration
dated 2026-08-31. The preparation script does not download anything.
Keep the resulting `xsd` directory under the repository root.

From VFP, with the repository root as the current directory, run:

```foxpro
LOCAL llOk
llOk = .F.
DO beispiele/06_erste_rechnung.prg WITH llOk
? llOk
```

Expected result: `.T.` and `erste-rechnung.xml`, with 139.97 net, 24.80 VAT and 164.77 gross.
The [complete source](../beispiele/06_erste_rechnung.prg) sets the parties, payment and lines.
The XML passes the library's business and enabled XSD checks. It is not a PDF.
Replace the sample business data before sending an invoice.

## Results and messages

`CreateXML(cDatei)` returns `.T.` after saving or `.F.` on failure.
An existing destination is preserved on failure, so file existence alone is not success.
`cLastError` contains the last error only. Warnings and information are in the message cursor,
a temporary FoxPro table, even when the method returns `.T.`.

Read the cursor before releasing the invoice object. Use a unique `cMeldungsCursor` alias
for every simultaneously live instance, set before its first use.
Use one object per invoice. Rejected Add calls remain errors; rebuild that object.

## PDF and limits

ZUGFeRD, also called Factur-X, combines a readable PDF and embedded CII XML.
`CreatePDF` can create this output for `EN16931` and `EXTENDED` using your own licensed
XFRX installation, version 19.0 or later. See [PDF with XFRX](XFRX.md).
It does not create a PDF for `XRECHNUNG-CII`.

Input strings use the active FoxPro ANSI code page. Output is UTF-8; characters that were
already lost in the input cannot be recovered. The application remains responsible for
the invoice's actual contents, tax treatment and recipient requirements.

## Documentation and license

The detailed documentation is in German: [concepts](GRUNDLAGEN.md), [integration](EINBAU.md),
[API](API.md), [messages](MELDUNGEN.md) and [calculations](RECHNEN.md).
The project's own code is [MIT licensed](../LICENSE).
Third-party schemas, specifications, code lists and XFRX are not included or licensed by
that MIT license. Redistributing third-party files requires separate written rights clearance.
