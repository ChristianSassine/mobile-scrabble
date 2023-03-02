import 'package:flutter/material.dart';
import 'package:mobile/components/theme-dropdown-widget.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () {
          showModalBottomSheet(context: context,
              builder: (BuildContext context){
                return SizedBox(
                  height: 100,
                  child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Themes :"),
                          ThemeDropdown(),
                        ],
                    ),
                  ),
                );
          });
        });
  }
}
