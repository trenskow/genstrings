genstring
----

Use this script to generate `Localized.strings`.

It looks for string that uses the below Swift extension.

> Copy/paste into your own code

    extension String {
        func localize(_ comment: String? = nil) {
            return NSLocalizedString(self, comment: comment ?? "")
        }
    }
    
Run the `main.swift` script of this repository in your root of your application sources, and it will generate a `Localized.strings` to standard out – pipe to desired file.
