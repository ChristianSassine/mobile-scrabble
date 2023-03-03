# Pre requirement
run `flutter pub get`

# To had any labels, there is 3 steps
1. Add your label in `assets/flutter_i18n/fr.json` and `assets/flutter_i18n/en.json`. Ex.:
```
{
    "myscreen": {
        "mylabel": "This is a label"
    }
}
```
2. Add at the start of the file `import 'package:flutter_i18n/flutter_i18n.dart';`
3. To get the translation string use `FlutterI18n.translate(context, "myscreen.mylabel")` which return a String
