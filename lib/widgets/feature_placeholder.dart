import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:flutter/material.dart';

Widget featurePlaceholder({
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return Center(
    child: emptyMessage(
      title: title,
      subtitle: subtitle,
      icon: icon,
    ),
  );
}

Widget featureScaffold({
  required String title,
  required String placeholderTitle,
  required String placeholderSubtitle,
  required IconData icon,
  bool hideBackIcon = false,
}) {
  return dinixMenuScaffold(
    title: title,
    body: featurePlaceholder(
      title: placeholderTitle,
      subtitle: placeholderSubtitle,
      icon: icon,
    ),
  );
}
