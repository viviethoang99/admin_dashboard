import 'package:flutter/material.dart';

class CourseDropdownTextField extends StatefulWidget {
  const CourseDropdownTextField({
    super.key,
    required this.onSubmitted,
  });

  final Function(String) onSubmitted;

  @override
  State<CourseDropdownTextField> createState() => CourseDropdownTextFieldState();
}

class CourseDropdownTextFieldState extends State<CourseDropdownTextField> {
  late TextEditingController courseName;

  List<String> dropdownList = <String>['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'];

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    // Perform your function when the TextField gains focus
    if (_isFocused) {
      showOverlay();
    } else {
      hideOverlay();
    }
  }

  OverlayEntry? entry;
  final layerLink = LayerLink();

  void showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 10),
          child: buildOverlay(),
        ),
      ),
    );
    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() => NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification? notification) {
          notification!.disallowIndicator();
          return true;
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 4 * 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onSubmitted(dropdownList[index]);
                  setState(() {});
                  hideOverlay();
                  _focusNode.unfocus();
                },
                child: Container(
                    padding: const EdgeInsets.all(20),
                    child: DefaultTextStyle(
                      style: const TextStyle(),
                      child: Text(
                        dropdownList[index],
                      ),
                    )),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 0,
                thickness: 3,
              );
            },
            itemCount: dropdownList.length,
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    courseName = TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: TextFormField(
        keyboardType: TextInputType.none,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Thêm thể loại',
          contentPadding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 12,
          ),
          hintStyle: const TextStyle(fontSize: 14, height: 1),
          labelStyle: const TextStyle(fontSize: 14, height: 1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
          ),
        ),
        controller: courseName,
        focusNode: _focusNode,
        onChanged: (value) {
          setState(() {
            courseName.text = value;
          });
        },
        onFieldSubmitted: widget.onSubmitted,
      ),
    );
  }
}
