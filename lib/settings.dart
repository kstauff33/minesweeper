import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences extends InheritedWidget {
  final PreferencesBloc bloc;

  Preferences({@required this.bloc, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static PreferencesBloc of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<Preferences>().bloc;
}

class SettingsState {}

class OpenSettings extends SettingsState {}

class CloseSettings extends SettingsState {}

class PreferencesBloc {
  final SharedPreferences _preferences;
  static const _COLUMN_KEY = 'COLUMNS';
  static const _BOMB_KEY = 'BOMBS';
  static const _ROW_KEY = 'ROWS';

  final state = BehaviorSubject<SettingsState>();

  PreferencesBloc({@required SharedPreferences preferences})
      : _preferences = preferences;

  get rows => _preferences.getInt(_ROW_KEY) ?? 24;

  set rows(int rows) => _preferences.setInt(_ROW_KEY, rows);

  get bombs => _preferences.getInt(_BOMB_KEY) ?? 200;

  set bombs(int bombs) => _preferences.setInt(_BOMB_KEY, bombs);

  get columns => _preferences.getInt(_COLUMN_KEY) ?? 30;

  set columns(int columns) => _preferences.setInt(_COLUMN_KEY, columns);

  void dispose() {
    state.close();
  }
}

class SettingsPanel extends StatelessWidget {
  final heightControl = TextEditingController();
  final widthControl = TextEditingController();
  final bombsControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var preferences = Preferences.of(context);
    heightControl.text = '${preferences.rows}';
    widthControl.text = '${preferences.columns}';
    bombsControl.text = '${preferences.bombs}';

    return AlertDialog(
      title: Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _getSettingsTextRow('Height', heightControl, context),
          _getSettingsTextRow('Width', widthControl, context),
          _getSettingsTextRow('Bombs', bombsControl, context),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Save'),
          onPressed: () => _saveSettings(preferences, context),
        )
      ],
    );
  }

  Widget _getSettingsTextRow(
      String text, TextEditingController controller, BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.end,
      maxLength: 2,
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter(new RegExp('[0-9]+'))],
      decoration: InputDecoration(
        labelText: text,
        counterText: '',
        fillColor: Theme.of(context).primaryColorLight,
      ),
    );
  }

  _saveSettings(PreferencesBloc preferences, BuildContext context) {
    var height = heightControl.value.text;
    var width = widthControl.value.text;
    var bombs = bombsControl.value.text;

    preferences.rows = int.parse(height);
    preferences.columns = int.parse(width);
    preferences.bombs = int.parse(bombs);
    Navigator.of(context)
      ..pop(true)
      ..popUntil((route) => route.isFirst);
  }
}
