# 🚀 FlutterFlow Quick Start

## Import và Sử dụng

### 1. Import library
```dart
import 'package:flutter_application_1/flutter_flow/flutter_flow.dart';
```

### 2. Sử dụng Theme
```dart
final theme = FlutterFlowTheme.of(context);

// Colors
theme.primaryColor
theme.secondaryColor
theme.primaryBackground
theme.primaryText

// Typography
theme.title1
theme.title2
theme.subtitle1
theme.bodyText1
```

### 3. Widgets Phổ biến

#### Button
```dart
FFButton(
  onPressed: () {},
  text: 'Click Me',
  options: FFButtonOptions(
    color: theme.primaryColor,
    borderRadius: BorderRadius.circular(8),
  ),
)
```

#### Icon Button
```dart
FFIconButton(
  icon: Icon(Icons.favorite),
  fillColor: theme.primaryColor,
  onPressed: () {},
)
```

### 4. Utilities

```dart
// Format date
dateTimeFormat('dd/MM/yyyy', DateTime.now())

// Format number
formatNumber(1234567, format: '#,###')

// Show snackbar
showSnackbar(context, 'Success!')

// Launch URL
await launchURL('https://example.com')

// Responsive
getMediaSize(context) // mobile, tablet, desktop
```

### 5. Animations
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with TickerProviderStateMixin, 
         AnimationControllerMixin<MyWidget> {
  
  @override
  void initState() {
    super.initState();
    setupAnimations({
      'fadeIn': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container()
      .animateOnPageLoad(animationsMap['fadeIn']!);
  }
}
```

## 📖 Chi tiết

Xem [FLUTTERFLOW_INTEGRATION.md](FLUTTERFLOW_INTEGRATION.md) để biết thêm chi tiết và examples.
