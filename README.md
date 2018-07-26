# PDFViewSubclasser
PDFKit sample

PDFView Subclasser shows you how to subclass PDFView in order to overlay content relative to the PDF content.

The PDFView method -[drawPage:] existed in Tiger (and is still present in Leopard).
The PDFView method -[drawPagePost:] is new in Leopard and so will not be called if run under Tiger.

Revision History

Leopard (no date) Version 1.0

2018-07-25 Version 2.0
Brought up-to-date in macOS 10.13.5 with Xcode 9.2
Base SDK 10.13
macOS Deployment Target 10.13
Repaired warnings and updated Deprecated APIs
Added Read Me with Revision History and Eratta

Errata

"Overridden deprecated methods" warning needs to be turned on and warnings repaired.

Turn on other warnings and fix issues that crop up.
https://github.com/boredzo/Warnings-xcconfig/wiki/Warnings-Explained
