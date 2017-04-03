genstrings
----

Use this script to generate `Localized.strings`.

----

Implement this somewhere in your code.

    extension String {
        func localize(_ comment: String? = nil) {
            return NSLocalizedString(self, comment: comment ?? "")
        }
    }

Then usage like this.

    var myString = "my identifier".localize()

– or with a comment.

    var myString = "my identifier".localize("my comment")

Run the `main.swift` script of this repository in your root of your application sources, and it will generate a `Localized.strings` to standard out – pipe to desired file.
