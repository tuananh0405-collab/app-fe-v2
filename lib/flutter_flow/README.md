# FlutterFlow Library Integration

Thư viện FlutterFlow đã được tích hợp vào dự án với các utilities và components phổ biến.

## 📦 Packages đã cài đặt

- `flutter_animate` - Animations framework
- `font_awesome_flutter` - Font Awesome icons
- `timeago` - Format thời gian relative
- `page_transition` - Page transitions
- `from_css_color` - Parse CSS colors
- `url_launcher` - Launch URLs
- `flutter_staggered_grid_view` - Staggered grid layouts

## 🚀 Cách sử dụng

### Import library

```dart
import 'package:flutter_application_1/flutter_flow/flutter_flow.dart';
```

### Theme System

```dart
// Sử dụng FlutterFlow theme
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Container(
      color: theme.primaryBackground,
      child: Text(
        'Hello FlutterFlow',
        style: theme.title1,
      ),
    );
  }
}
```

### Colors có sẵn

- `primaryColor` - Màu chính
- `secondaryColor` - Màu phụ
- `tertiaryColor` - Màu thứ ba
- `primaryBackground` - Background chính
- `secondaryBackground` - Background phụ
- `primaryText` - Text chính
- `secondaryText` - Text phụ
- `error`, `success`, `warning`, `info` - Màu trạng thái

### Typography Styles

```dart
theme.title1      // 24px, bold
theme.title2      // 22px, medium
theme.title3      // 20px, medium
theme.subtitle1   // 18px, medium
theme.subtitle2   // 16px, normal
theme.bodyText1   // 14px, normal
theme.bodyText2   // 14px, normal
```

### Widgets

#### FFButton

```dart
FFButton(
  onPressed: () {},
  text: 'Click Me',
  icon: Icon(Icons.add),
  options: FFButtonOptions(
    width: 200,
    height: 50,
    color: theme.primaryColor,
    textStyle: theme.subtitle2.override(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.circular(12),
    elevation: 2,
  ),
)
```

#### FFIconButton

```dart
FFIconButton(
  icon: Icon(Icons.favorite),
  borderRadius: 20,
  buttonSize: 40,
  fillColor: theme.primaryColor,
  onPressed: () {},
)
```

#### FFLoadingIndicator

```dart
FFLoadingIndicator(
  size: 50,
  color: theme.primaryColor,
)
```

### Animations

```dart
class MyAnimatedWidget extends StatefulWidget {
  @override
  State<MyAnimatedWidget> createState() => _MyAnimatedWidgetState();
}

class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with TickerProviderStateMixin, AnimationControllerMixin {
  
  @override
  void initState() {
    super.initState();
    setupAnimations({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: Duration(milliseconds: 100),
          duration: Duration(milliseconds: 600),
        ),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Animated Widget'),
    ).animateOnPageLoad(
      animationsMap['containerOnPageLoadAnimation']!,
    );
  }
}
```

### Utilities

#### Date Formatting

```dart
String formatted = dateTimeFormat('dd/MM/yyyy', DateTime.now());
String relative = dateTimeFormat('relative', DateTime.now());
```

#### Number Formatting

```dart
String formatted = formatNumber(1234567, format: '#,###');
String currency = formatNumber(1234.56, currency: 'USD');
String compact = formatNumber(1000000, compact: true); // 1M
```

#### URL Launcher

```dart
await launchURL('https://example.com');
```

#### Snackbar

```dart
showSnackbar(context, 'Success!');
showSnackbar(context, 'Loading...', loading: true, duration: 10);
```

#### Responsive Design

```dart
final mediaSize = getMediaSize(context);
if (mediaSize == MediaSize.mobile) {
  // Mobile layout
} else if (mediaSize == MediaSize.tablet) {
  // Tablet layout
} else {
  // Desktop layout
}

// Hoặc sử dụng constants
if (MediaQuery.sizeOf(context).width <= kBreakpointSmall) {
  // Mobile
}
```

### Models

#### LatLng

```dart
final location = LatLng(37.7749, -122.4194);
final distance = location.distanceTo(LatLng(34.0522, -118.2437)); // km
```

#### FFPlace

```dart
final place = FFPlace(
  latLng: LatLng(37.7749, -122.4194),
  name: 'San Francisco',
  address: '123 Main St',
  city: 'San Francisco',
  state: 'CA',
  country: 'USA',
  zipCode: '94102',
);
```

#### FFUploadedFile

```dart
final file = FFUploadedFile(
  name: 'image.jpg',
  bytes: imageBytes,
  height: 1920,
  width: 1080,
);
```

## 🎨 Customization

### Thay đổi Theme Colors

Chỉnh sửa `lib/flutter_flow/flutter_flow_theme.dart`:

```dart
class LightModeTheme extends FlutterFlowTheme {
  @override
  Color primaryColor = const Color(0xFFYOUR_COLOR);
  // ...
}
```

### Thêm Custom Animations

```dart
static List<Effect> myCustomAnimation() => [
  FadeEffect(duration: Duration(milliseconds: 300)),
  ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0)),
  RotateEffect(begin: 0, end: 0.1),
];
```

## 📖 Resources

- [FlutterFlow Documentation](https://docs.flutterflow.io/)
- [Flutter Animate Package](https://pub.dev/packages/flutter_animate)
- [Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter)

## 💡 Best Practices

1. **Sử dụng theme colors** thay vì hardcode colors
2. **Dùng responsive utilities** cho layout đa thiết bị
3. **Tận dụng animations** để tăng UX
4. **Format numbers và dates** theo locale
5. **Sử dụng các widgets có sẵn** để đảm bảo consistency

## 🔧 Migration từ code cũ

### Before
```dart
Container(
  color: Colors.blue,
  child: Text('Title', style: TextStyle(fontSize: 24)),
)
```

### After
```dart
Container(
  color: FlutterFlowTheme.of(context).primaryColor,
  child: Text('Title', style: FlutterFlowTheme.of(context).title1),
)
```
