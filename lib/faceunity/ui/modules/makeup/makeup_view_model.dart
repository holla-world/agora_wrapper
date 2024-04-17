import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../plugins/makeup_plugin.dart';
import '../../util/common_util.dart';
import 'makeup_model.dart';

class MakeupViewModel extends ChangeNotifier {

  MakeupViewModel() : super() {
    getMakeups();
  }

  late List<MakeupModel> makeups = [];

  int selectedIndex = 0;

  void setSelectedIndex(int index) {
    if (index < 0 || index >= makeups.length) {
      return;
    }
    selectedIndex = index;
    if (index == 0) {
      MakeupPluin.removeMakeup();
    } else {
      MakeupPluin.selectMakeup(makeups[index].bundleName, makeups[index].isCombined, makeups[index].value);
      setMakeupIntensity(makeups[index].value);
    }
  }

  void setMakeupIntensity(double intensity) {
    if (selectedIndex < 0 || selectedIndex >= makeups.length) {
      return;
    }
    intensity = intensity < 0 ? 0 : (intensity > 1 ? 1 : intensity);
    makeups[selectedIndex].value = intensity;
    MakeupPluin.setMakeupIntensity(intensity);
  }

  void getMakeups() async {
    String jsonString = await rootBundle.loadString(CommonUtil.bundleFileNamed("makeup/makeups.json"));
    final jsonData = json.decode(jsonString);
    List<MakeupModel> makeupModels = [];
    for (Map<String, dynamic> item in jsonData) {
      MakeupModel makeup = MakeupModel.fromJson(item);
      makeupModels.add(makeup);
    }
    makeups = makeupModels;
    notifyListeners();
  }
}