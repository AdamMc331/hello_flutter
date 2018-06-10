// To keep your imports tidy, follow the ordering guidelines at
// https://www.dartlang.org/guides/language/effective-dart/style#ordering
import 'package:flutter/material.dart';

const _containerPadding = EdgeInsets.all(8.0);
const _iconPadding = EdgeInsets.all(16.0);
const _height = 100.0;
const _radius = _height / 2.0;
const _textStyle = TextStyle(fontSize: 24.0);
const _iconSize = 60.0;
const _iconWidth = 70.0;

/// A custom [Category] widget.
///
/// The widget is composed on an [Icon] and [Text]. Tapping on the widget shows
/// a colored [InkWell] animation.
class Category extends StatelessWidget {
  final String name;
  final Color color;
  final IconData iconLocation;

  /// Creates a [Category].
  ///
  /// A [Category] saves the name of the Category (e.g. 'Length'), its color for
  /// the UI, and the icon that represents it (e.g. a ruler).
  const Category({
    Key key,
    @required this.name,
    @required this.color,
    @required this.iconLocation,
  })  : assert(name != null),
        assert(color != null),
        assert(iconLocation != null),
        super(key: key);

  /// Builds a custom widget that shows [Category] information.
  ///
  /// This information includes the icon, name, and color for the [Category].
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _height,
        child: InkWell(
          splashColor: color,
          highlightColor: color,
          borderRadius: BorderRadius.circular(_radius),
          onTap: () {
            print('I was tapped!');
          },
          child: Padding(
            padding: _containerPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: _iconPadding,
                  child: Icon(
                    iconLocation,
                    size: _iconSize,
                  ),
                ),
                Center(
                  child: Text(
                    name,
                    style: _textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
