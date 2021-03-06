import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class SettingsEditorsScreen extends StatefulWidget {
  @override
  SettingsEditorsScreenState createState() => SettingsEditorsScreenState();
}

class SettingsEditorsScreenState extends State<SettingsEditorsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;
    var defaultNewFolder =
        Settings.instance.journalEditordefaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = tr("rootFolder");
    } else {
      if (!folderWithSpecExists(context, defaultNewFolder)) {
        setState(() {
          defaultNewFolder = tr("rootFolder");

          Settings.instance.journalEditordefaultNewNoteFolderSpec = "";
          Settings.instance.save();
        });
      }
    }

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.editors.defaultEditor"),
        currentOption: settings.defaultEditor.toPublicString(),
        options:
            SettingsEditorType.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var val = SettingsEditorType.fromPublicString(publicStr);
          Settings.instance.defaultEditor = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SettingsHeader(tr("settings.editors.markdownEditor")),
      ListPreference(
        title: tr("settings.editors.defaultState"),
        currentOption: settings.markdownDefaultView.toPublicString(),
        options: SettingsMarkdownDefaultView.options
            .map((f) => f.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          var val = SettingsMarkdownDefaultView.fromPublicString(publicStr);
          Settings.instance.markdownDefaultView = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SettingsHeader(tr("settings.editors.journalEditor")),
      ProOverlay(
        child: ListTile(
          title: Text(tr("settings.editors.defaultFolder")),
          subtitle: Text(defaultNewFolder),
          onTap: () async {
            var destFolder = await showDialog<NotesFolderFS>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );

            Settings.instance.journalEditordefaultNewNoteFolderSpec =
                destFolder != null ? destFolder.pathSpec() : "";
            Settings.instance.save();
            setState(() {});
          },
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.editors.title")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }
}
