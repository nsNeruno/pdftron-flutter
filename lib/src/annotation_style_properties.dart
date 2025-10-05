import 'dart:ui';

/// Represents style properties that can be applied to annotations.
/// 
/// This class provides strongly-typed properties for annotation styling,
/// ensuring type safety and better IDE support.
/// 
/// Example usage:
/// ```dart
/// final style = AnnotationStyleProperties()
///   ..strokeColor = const Color(0xFFFF0000)  // Red
///   ..opacity = 0.5
///   ..strokeWidth = 2.0;
/// 
/// await controller.setDefaultStyleForTool(
///   Tools.annotationCreateTextHighlight,
///   style
/// );
/// ```
class AnnotationStyleProperties {
  /// The stroke/outline color of the annotation.
  /// 
  /// This affects the main color of most annotations.
  /// For text annotations, this is the text color.
  /// For shapes with borders, this is the border color.
  Color? strokeColor;

  /// The fill color for shape annotations.
  /// 
  /// Only applicable to closed shapes like rectangles, circles, and polygons.
  /// Has no effect on line-based or text annotations.
  Color? fillColor;

  /// The opacity/transparency of the annotation.
  /// 
  /// Value should be between 0.0 (fully transparent) and 1.0 (fully opaque).
  /// Only applies to markup annotations.
  double? opacity;

  /// The stroke width/thickness in points.
  /// 
  /// Affects the thickness of lines, borders, and ink annotations.
  /// Has no effect on text or sticky note annotations.
  double? strokeWidth;

  /// The font size for text annotations.
  /// 
  /// Only applicable to free text and callout annotations.
  /// Has no effect on other annotation types.
  double? fontSize;

  /// Creates an empty AnnotationStyleProperties instance.
  AnnotationStyleProperties();

  /// Creates an AnnotationStyleProperties instance from a map.
  /// 
  /// This constructor is useful when receiving style data from platform channels
  /// or when loading saved style configurations.
  AnnotationStyleProperties.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('color') && map['color'] != null) {
      strokeColor = _parseColor(map['color']);
    }
    if (map.containsKey('fillColor') && map['fillColor'] != null) {
      fillColor = _parseColor(map['fillColor']);
    }
    if (map.containsKey('opacity') && map['opacity'] != null) {
      opacity = _clampOpacity(map['opacity']);
    }
    if (map.containsKey('thickness') && map['thickness'] != null) {
      strokeWidth = map['thickness']?.toDouble();
    }
    if (map.containsKey('fontSize') && map['fontSize'] != null) {
      fontSize = map['fontSize']?.toDouble();
    }
  }

  /// Converts the style properties to a map for platform channel communication.
  /// 
  /// Only non-null properties are included in the resulting map.
  /// Colors are converted to hex strings for cross-platform compatibility.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    
    if (strokeColor != null) {
      map['color'] = _colorToHex(strokeColor!);
    }
    if (fillColor != null) {
      map['fillColor'] = _colorToHex(fillColor!);
    }
    if (opacity != null) {
      map['opacity'] = _clampOpacity(opacity!);
    }
    if (strokeWidth != null) {
      map['thickness'] = strokeWidth;
    }
    if (fontSize != null) {
      map['fontSize'] = fontSize;
    }
    
    return map;
  }

  /// Creates a copy of this AnnotationStyleProperties with the given fields replaced.
  AnnotationStyleProperties copyWith({
    Color? strokeColor,
    Color? fillColor,
    double? opacity,
    double? strokeWidth,
    double? fontSize,
  }) {
    return AnnotationStyleProperties()
      ..strokeColor = strokeColor ?? this.strokeColor
      ..fillColor = fillColor ?? this.fillColor
      ..opacity = opacity ?? this.opacity
      ..strokeWidth = strokeWidth ?? this.strokeWidth
      ..fontSize = fontSize ?? this.fontSize;
  }

  /// Merges this style with another, with the other style taking precedence.
  /// 
  /// Useful for applying partial style updates or cascading styles.
  AnnotationStyleProperties merge(AnnotationStyleProperties other) {
    return AnnotationStyleProperties()
      ..strokeColor = other.strokeColor ?? strokeColor
      ..fillColor = other.fillColor ?? fillColor
      ..opacity = other.opacity ?? opacity
      ..strokeWidth = other.strokeWidth ?? strokeWidth
      ..fontSize = other.fontSize ?? fontSize;
  }

  /// Validates that the style properties have reasonable values.
  /// 
  /// Returns a list of validation errors, or an empty list if valid.
  List<String> validate() {
    final errors = <String>[];
    
    if (opacity != null && (opacity! < 0.0 || opacity! > 1.0)) {
      errors.add('Opacity must be between 0.0 and 1.0');
    }
    if (strokeWidth != null && strokeWidth! < 0.0) {
      errors.add('Stroke width must be non-negative');
    }
    if (fontSize != null && fontSize! <= 0.0) {
      errors.add('Font size must be positive');
    }
    
    return errors;
  }

  /// Converts a Color to a hex string.
  String _colorToHex(Color color) {
    // Format: #RRGGBB (ignoring alpha channel for compatibility)
    final r = (color.red * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.green * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.blue * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }

  /// Parses a color from various input formats.
  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    
    if (value is Color) {
      return value;
    }
    
    if (value is String) {
      // Remove # if present
      String hex = value.replaceAll('#', '');
      
      // Handle different hex lengths
      if (hex.length == 6) {
        // RGB format
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return Color.fromRGBO(r, g, b, 1.0);
      } else if (hex.length == 8) {
        // ARGB format
        final a = int.parse(hex.substring(0, 2), radix: 16);
        final r = int.parse(hex.substring(2, 4), radix: 16);
        final g = int.parse(hex.substring(4, 6), radix: 16);
        final b = int.parse(hex.substring(6, 8), radix: 16);
        return Color.fromRGBO(r, g, b, a / 255.0);
      }
    }
    
    if (value is int) {
      // Assume it's a color value in ARGB format
      return Color(value);
    }
    
    return null;
  }

  /// Clamps opacity value between 0.0 and 1.0.
  double _clampOpacity(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    return 1.0;
  }

  @override
  String toString() {
    final parts = <String>[];
    if (strokeColor != null) parts.add('strokeColor: ${_colorToHex(strokeColor!)}');
    if (fillColor != null) parts.add('fillColor: ${_colorToHex(fillColor!)}');
    if (opacity != null) parts.add('opacity: $opacity');
    if (strokeWidth != null) parts.add('strokeWidth: $strokeWidth');
    if (fontSize != null) parts.add('fontSize: $fontSize');
    return 'AnnotationStyleProperties(${parts.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnnotationStyleProperties) return false;
    
    return strokeColor == other.strokeColor &&
           fillColor == other.fillColor &&
           opacity == other.opacity &&
           strokeWidth == other.strokeWidth &&
           fontSize == other.fontSize;
  }

  @override
  int get hashCode {
    return Object.hash(
      strokeColor,
      fillColor,
      opacity,
      strokeWidth,
      fontSize,
    );
  }
}

/// Predefined common annotation styles for convenience.
class AnnotationStyles {
  AnnotationStyles._();

  /// Default red highlight style with 50% opacity.
  static final highlight = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFFFFFF00)  // Yellow
    ..opacity = 0.5;

  /// Default blue ink style with 2pt width.
  static final ink = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFF0000FF)  // Blue
    ..strokeWidth = 2.0
    ..opacity = 1.0;

  /// Default red strikeout style.
  static final strikeout = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFFFF0000)  // Red
    ..opacity = 0.8;

  /// Default green underline style.
  static final underline = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFF00FF00)  // Green
    ..opacity = 0.8;

  /// Default black text style with 12pt font.
  static final freeText = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFF000000)  // Black
    ..fontSize = 12.0
    ..opacity = 1.0;

  /// Default red rectangle with semi-transparent fill.
  static final rectangle = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFFFF0000)  // Red border
    ..fillColor = const Color(0xFFFF0000)   // Red fill
    ..strokeWidth = 2.0
    ..opacity = 0.3;

  /// Default arrow style with black color and 2pt width.
  static final arrow = AnnotationStyleProperties()
    ..strokeColor = const Color(0xFF000000)  // Black
    ..strokeWidth = 2.0
    ..opacity = 1.0;
}