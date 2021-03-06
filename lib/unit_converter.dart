import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'category.dart';
import 'unit.dart';
import 'api.dart';
import 'dart:async';

const _padding = EdgeInsets.all(16.0);

/// Converter screen where users can input amounts to convert.
class UnitConverter extends StatefulWidget {
  final Category category;

  const UnitConverter({
    @required this.category,
  }) : assert(category != null);

  @override
  State<StatefulWidget> createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<UnitConverter> {
  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  String _convertedValue = "";
  List<DropdownMenuItem> _unitMenuItems;
  bool _showErrorUI = false;
  bool _showValidationError = false;
  final _inputKey = GlobalKey(debugLabel: 'inputText');

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  /// Whenever configuration updates, we need to rest dropdown if we've
  /// changed categories.
  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);

    if (old.category != widget.category) {
      _createDropdownMenuItems();
      _setDefaults();
    }
  }

  /// Builds the list of dropdown units for the current category.
  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }

    setState(() {
      _unitMenuItems = newItems;
    });
  }

  /// Sets a default from/to value with the units we have.
  void _setDefaults() {
    setState(() {
      _fromValue = widget.category.units[0];
      _toValue = widget.category.units[1];
    });
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  /// Updates the conversion value. This is called anytime the user selects a
  /// different from or to unit.
  Future<void> _updateConversion() async {
    // Our API has a handy convert function, so we can use that for
    // the Currency [Category]
    if (widget.category.name == apiCategory['name']) {
      final api = Api();
      final conversion = await api.convert(apiCategory['route'],
          _inputValue.toString(), _fromValue.name, _toValue.name);

      setState(() {
        if (conversion == null) {
          _showErrorUI = true;
        } else {
          _showErrorUI = false;
          _convertedValue = _format(conversion);
        }
      });
    } else {
      // For the static units, we do the conversion ourselves
      setState(() {
        _convertedValue = _format(
            _inputValue * (_toValue.conversion / _fromValue.conversion));
      });
    }
  }

  /// Validates the input value based on input, throwing an error if we get
  /// anything that isn't a double.
  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = "";
      } else {
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print("Error: $e");
          _showValidationError = true;
        }
      }
    });
  }

  /// Retrieves an actual [Unit] instance given a string name.
  Unit _getUnit(String unitName) {
    return widget.category.units.firstWhere(
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  /// Anytime the user changes the from value, we need to update the conversion
  /// if necessary.
  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });

    if (_inputValue != null) {
      _updateConversion();
    }
  }

  /// Anytime the user changes the to value, we need to update the conversion
  /// if necessary.
  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });

    if (_inputValue != null) {
      _updateConversion();
    }
  }

  /// Builds a drop down for the conversion units. It takes in a currentValue to
  /// set as the selected one, and an [onChanged] function to call when the user
  /// selects something new in the drop down.
  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        // Sets the color of the [DropDownButton] itself
        color: Colors.grey[5],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        // Sets the color of the [DropdownMenuItem]
        data: Theme.of(context).copyWith(
              canvasColor: Colors.grey[50],
            ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentValue,
              items: _unitMenuItems,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an error UI to display whenever we have an API error.
  Widget _buildErrorUI(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: _padding,
        padding: _padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: widget.category.color['error'],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 180.0,
              color: Colors.white,
            ),
            Text(
              "Oh no! We can't connect right now!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the UI widget for the input of a conversion.
  Widget _buildInputUI(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // This is the widget that accepts text input. In this case, it accepts
          // numbers and calls the onChanged property on update.
          TextField(
            key: _inputKey,
            style: Theme.of(context).textTheme.display1,
            decoration: InputDecoration(
              labelStyle: Theme.of(context).textTheme.display1,
              errorText:
              _showValidationError ? "Invalid number entered." : null,
              labelText: "Input",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            // Since we only want numerical input, we use a number keyboard.
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          _createDropdown(_fromValue.name, _updateFromConversion),
        ],
      ),
    );
  }

  /// Builds the UI Widget to display the output of a conversion.
  Widget _buildOutputUI(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              labelText: "Output",
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdown(_toValue.name, _updateToConversion)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.units == null ||
        (widget.category.name == apiCategory['name'] && _showErrorUI)) {
      return _buildErrorUI(context);
    }

    final input = _buildInputUI(context);

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    final output = _buildOutputUI(context);

    final converter = ListView(
      children: <Widget>[
        input,
        arrows,
        output,
      ],
    );

    // If we're in portrait, use the converter we built. Otherwise, let's center
    // all of the elements.
    return Padding(
      padding: _padding,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.portrait) {
            return converter;
          } else {
            return Center(
              child: Container(
                width: 450.0,
                child: converter,
              ),
            );
          }
        },
      ),
    );
  }
}
