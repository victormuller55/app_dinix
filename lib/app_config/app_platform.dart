import 'dart:io';

import 'package:flutter/foundation.dart';

bool get isIOSPlatform => !kIsWeb && Platform.isIOS;

bool get isAndroidPlatform => !kIsWeb && Platform.isAndroid;
