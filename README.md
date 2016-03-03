# CSWPasscodeViewController
=========================
Base on [LTHPasscodeViewController](https://github.com/rolandleth/LTHPasscodeViewController) by [rolandleth](https://github.com/rolandleth).

Passcode lock with TouchID that takes a picture on the front camera when invalid passcode is entered

CSWPasscodeViewController is a subclass of LTHPasscodeViewController that adds two additional features to the base class. Set #define PASSLEN to 4, to show the standard 4 digit passcode. Set #define PASSLEN to 6, to use a 6 digit passcode.

Additionally, when an incorrect passcode is entered the front camera takes a picture trying to capture an image of who entered the incorrect passcode. If TouchID is used, a picture is taken after 3 incorrect tries.

# License
Licensed under MIT. 
