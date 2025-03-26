import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'controllers/future_controller.dart';
part 'controllers/multiselect_controller.dart';
part 'enum/enums.dart';
part 'models/decoration.dart';
part 'models/dropdown_item.dart';
// part 'models/network_request.dart';
part 'widgets/dropdown.dart';

/// typedef for the dropdown item builder.
typedef DropdownItemBuilder<T> = Widget Function(
  DropdownItem<T> item,
  int index,
  VoidCallback onTap,
);

/// typedef for the callback when the item is selected/de-selected/disabled.
typedef OnSelectionChanged<T> = void Function(List<T> selectedItems);

/// typedef for the callback when the search field value changes.
typedef OnSearchChanged = ValueChanged<String>;

/// typedef for the selected item builder.
typedef SelectedItemBuilder<T> = Widget Function(DropdownItem<T> item);

/// typedef for the future request.
typedef FutureRequest<T> = Future<List<DropdownItem<T>>> Function();

/// A multiselect dropdown widget.
///
class MultiDropdown<T extends Object?> extends StatefulWidget {
  /// Creates a multiselect dropdown widget.
  ///
  /// The [items] are the list of dropdown items. It is required.
  ///
  /// The [fieldDecoration] is the decoration of the field. The default value is FieldDecoration().
  /// It can be used to customize the field decoration.
  ///
  /// The [dropdownDecoration] is the decoration of the dropdown. The default value is DropdownDecoration().
  /// It can be used to customize the dropdown decoration.
  ///
  /// The [searchDecoration] is the decoration of the search field. The default value is SearchFieldDecoration().
  /// It can be used to customize the search field decoration.
  /// If [searchEnabled] is true, then the search field will be displayed.
  ///
  /// The [dropdownItemDecoration] is the decoration of the dropdown items. The default value is DropdownItemDecoration().
  /// It can be used to customize the dropdown item decoration.
  ///
  /// The [autovalidateMode] is the autovalidate mode for the dropdown. The default value is AutovalidateMode.disabled.
  ///
  /// The [singleSelect] is the selection type of the dropdown. The default value is false.
  /// If true, only one item can be selected at a time.
  ///
  /// The [itemSeparator] is the separator between the dropdown items.
  ///
  /// The [controller] is the controller for the dropdown. It can be used to control the dropdown programmatically.
  ///
  /// The [validator] is the validator for the dropdown. It can be used to validate the dropdown.
  ///
  /// The [itemBuilder] is the builder for the dropdown items. If not provided, the default ListTile will be used.
  ///
  /// The [enabled] is whether the dropdown is enabled. The default value is true.
  ///
  /// The [chipDecoration] is the configuration for the chips. The default value is ChipDecoration().
  /// It can be used to customize the chip decoration. The chips are displayed when an item is selected.
  ///
  /// The [searchEnabled] is whether the search field is enabled. The default value is false.
  ///
  /// The [searchController] is the controller of the search field.
  ///
  /// The [maxSelections] is the maximum number of selections allowed. The default value is 0.
  ///
  /// The [selectedItemBuilder] is the builder for the selected items. If not provided, the default Chip will be used.
  ///
  /// The [focusNode] is the focus node for the dropdown.
  ///
  /// The [onSelectionChange] is the callback when the item is changed.
  ///
  /// The [closeOnBackButton] is whether to close the dropdown when the back button is pressed. The default value is false.
  /// Note: This option requires the app to have a router, such as MaterialApp.router, in order to work properly.
  ///
  /// The [responsiveSearch] indicates if the future request will be redone when the search text is changed.
  ///
  /// The [canAddTempOption] is the flag to manually add a temporary option.
  /// Allows to add new temporary option
  ///
  /// The [noItemsFoundMessage] is the message displayed when the search returns no items.
  ///
  const MultiDropdown({
    required this.items,
    this.fieldDecoration = const FieldDecoration(),
    this.dropdownDecoration = const DropdownDecoration(),
    this.searchDecoration = const SearchFieldDecoration(),
    this.dropdownItemDecoration = const DropdownItemDecoration(),
    this.autovalidateMode = AutovalidateMode.disabled,
    this.singleSelect = false,
    this.itemSeparator,
    this.controller,
    this.validator,
    this.itemBuilder,
    this.enabled = true,
    this.chipDecoration = const ChipDecoration(),
    this.searchEnabled = false,
    this.searchController,
    this.maxSelections = 0,
    this.selectedItemBuilder,
    this.focusNode,
    this.onSelectionChange,
    this.onSearchChange,
    this.closeOnBackButton = false,
    this.canAddTempOption = false,
    this.noItemsFoundMessage,
    super.key,
  })  : future = null,
        responsiveSearch = false;

  /// Creates a multiselect dropdown widget with future request.
  ///
  /// The [future] is the future request for the dropdown items.
  /// You can use this to fetch the dropdown items asynchronously.
  ///
  /// A loading indicator will be displayed while the future is in progress at the suffix icon.
  /// The dropdown will be disabled until the future is completed.
  ///
  /// Example:
  ///
  /// ```dart
  /// MultiDropdown<User>.future(
  ///  future: () async {
  ///   final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
  ///  final data = jsonDecode(response.body) as List;
  /// return data.map((e) => DropdownItem(
  ///  label: e['name'] as String,
  /// value: e['id'] as int,
  /// )).toList();
  /// },
  /// );
  ///
  /// ```
  const MultiDropdown.future({
    required this.future,
    this.fieldDecoration = const FieldDecoration(),
    this.dropdownDecoration = const DropdownDecoration(),
    this.searchDecoration = const SearchFieldDecoration(),
    this.dropdownItemDecoration = const DropdownItemDecoration(),
    this.autovalidateMode = AutovalidateMode.disabled,
    this.singleSelect = false,
    this.itemSeparator,
    this.controller,
    this.validator,
    this.itemBuilder,
    this.enabled = true,
    this.chipDecoration = const ChipDecoration(),
    this.searchEnabled = false,
    this.searchController,
    this.maxSelections = 0,
    this.selectedItemBuilder,
    this.focusNode,
    this.onSelectionChange,
    this.onSearchChange,
    this.closeOnBackButton = false,
    this.responsiveSearch = false,
    this.canAddTempOption = false,
    this.noItemsFoundMessage,
    this.items = const [],
    super.key,
  });

  /// The list of dropdown items.
  final List<DropdownItem<T>> items;

  /// The selection type of the dropdown.
  final bool singleSelect;

  /// The configuration for the chips.
  final ChipDecoration chipDecoration;

  /// The decoration of the field.
  final FieldDecoration fieldDecoration;

  /// The decoration of the dropdown.
  final DropdownDecoration dropdownDecoration;

  /// The decoration of the search field.
  final SearchFieldDecoration searchDecoration;

  /// The controller of the search field text.
  final TextEditingController? searchController;

  /// The decoration of the dropdown items.
  final DropdownItemDecoration dropdownItemDecoration;

  /// The builder for the dropdown items.
  final DropdownItemBuilder<T>? itemBuilder;

  /// The builder for the selected items.
  final SelectedItemBuilder<T>? selectedItemBuilder;

  /// The separator between the dropdown items.
  final Widget? itemSeparator;

  /// The validator for the dropdown.
  final String? Function(List<DropdownItem<T>>? selectedOptions)? validator;

  /// The autovalidate mode for the dropdown.
  final AutovalidateMode autovalidateMode;

  /// The controller for the dropdown.
  final MultiSelectController<T>? controller;

  /// The maximum number of selections allowed.
  final int maxSelections;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Whether the search field is enabled.
  final bool searchEnabled;

  /// The focus node for the dropdown.
  final FocusNode? focusNode;

  /// The future request for the dropdown items.
  final FutureRequest<T>? future;

  /// The callback when the item is changed.
  ///
  /// This callback is called when any item is selected or unselected.
  final OnSelectionChanged<DropdownItem<T>>? onSelectionChange;

  /// The callback when the search field value changes.
  final OnSearchChanged? onSearchChange;

  /// Whether to close the dropdown when the back button is pressed.
  ///
  /// Note: This option requires the app to have a router, such as MaterialApp.router, in order to work properly.
  final bool closeOnBackButton;

  /// Indicates if the future request will be redone when the search text is changed.
  final bool responsiveSearch;

  /// Allows to add new temporary option
  final bool canAddTempOption;

  /// The message displayed when the search returns no items.
  final String? noItemsFoundMessage;

  @override
  State<MultiDropdown<T>> createState() => _MultiDropdownState<T>();
}

class _MultiDropdownState<T extends Object?> extends State<MultiDropdown<T>> {
  final LayerLink _layerLink = LayerLink();

  final OverlayPortalController _portalController = OverlayPortalController();

  late MultiSelectController<T> _dropdownController = widget.controller ?? MultiSelectController<T>();
  final _FutureController _loadingController = _FutureController();

  late FocusNode _focusNode = widget.focusNode ?? FocusNode();

  late final Listenable _listenable = Listenable.merge([
    _dropdownController,
    _loadingController,
  ]);

  // the global key for the form field state to update the form field state when the controller changes
  final GlobalKey<FormFieldState<List<DropdownItem<T>>?>> _formFieldKey = GlobalKey();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_dropdownController.isDisposed) {
      throw StateError('DropdownController is disposed');
    }

    if (widget.future != null) {
      if (!widget.responsiveSearch) {
        unawaited(handleFuture());
      } else {
        _dropdownController
          .._searchQuery = '.'
          ..setItemsKeepingSelecteds(
            widget.items,
            selectionChanged: false,
          );
      }
    }

    if (!_dropdownController._initialized) {
      _dropdownController
        .._initialize()
        ..setItems(
          widget.items,
          selectionChanged: false,
        );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropdownController
        ..addListener(_controllerListener)
        .._setOnSelectionChange(widget.onSelectionChange)
        .._setOnSearchChange(widget.onSearchChange);

      // if close on back button is enabled, then add the listener
      _listenBackButton();
    });
  }

  void _listenBackButton() {
    if (!widget.closeOnBackButton) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _registerBackButtonDispatcherCallback();
      } catch (e) {
        debugPrint('Error: $e');
      }
    });
  }

  void _registerBackButtonDispatcherCallback() {
    final rootBackDispatcher = Router.of(context).backButtonDispatcher;

    if (rootBackDispatcher != null) {
      rootBackDispatcher.createChildBackButtonDispatcher()
        ..addCallback(() {
          if (_dropdownController.isOpen) {
            _closeDropdown();
          }

          return Future.value(true);
        })
        ..takePriority();
    }
  }

  Future<void> handleFuture() async {
    // we need to wait for the future to complete
    // before we can set the items to the dropdown controller.

    try {
      _loadingController.start();
      final items = await widget.future!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadingController.stop();
        if (widget.responsiveSearch && !widget.singleSelect) {
          _dropdownController
            .._searchQuery = '.'
            ..setItemsKeepingSelecteds(items);
        } else {
          _dropdownController.setItems(
            items,
            setFilteredItems: widget.responsiveSearch,
            selectionChanged: false,
          );
        }
      });
    } catch (e) {
      _loadingController.stop();
      rethrow;
    }
  }

  void _controllerListener() {
    // update the form field state when the controller changes
    _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);

    if (_dropdownController.isOpen) {
      _portalController.show();
    } else {
      _dropdownController._clearSearchQuery();
      _portalController.hide();
    }
  }

  @override
  void didUpdateWidget(covariant MultiDropdown<T> oldWidget) {
    // if the controller is changed, then dispose the old controller
    // and initialize the new controller.
    if (oldWidget.controller != widget.controller) {
      _dropdownController
        ..removeListener(_controllerListener)
        ..dispose();

      _dropdownController = widget.controller ?? MultiSelectController<T>();

      _initializeController();
    }

    // if the focus node is changed, then dispose the old focus node
    // and initialize the new focus node.
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _dropdownController.removeListener(_controllerListener);

    if (widget.controller == null) {
      _dropdownController.dispose();
    }

    _loadingController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<DropdownItem<T>>?>(
      key: _formFieldKey,
      validator: widget.validator ?? (_) => null,
      autovalidateMode: widget.autovalidateMode,
      initialValue: _dropdownController.selectedItems,
      enabled: widget.enabled,
      builder: (_) {
        return OverlayPortal(
          controller: _portalController,
          overlayChildBuilder: (_) {
            final renderBox = context.findRenderObject() as RenderBox?;

            if (renderBox == null || !renderBox.attached) {
              _showError('Failed to build the dropdown\nCode: 08');
              return const SizedBox();
            }

            final renderBoxSize = renderBox.size;
            final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

            final availableHeight =
                MediaQuery.of(context).size.height - renderBoxOffset.dy - renderBoxSize.height - (widget.searchEnabled ? 60 : 0) - 100;

            final showOnTop = availableHeight < widget.dropdownDecoration.maxHeight;

            final stack = Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _handleOutsideTap,
                  ),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  targetAnchor: showOnTop ? Alignment.topLeft : Alignment.bottomLeft,
                  followerAnchor: showOnTop ? Alignment.bottomLeft : Alignment.topLeft,
                  offset: widget.dropdownDecoration.marginTop == 0 ? Offset.zero : Offset(0, widget.dropdownDecoration.marginTop),
                  child: RepaintBoundary(
                    child: _Dropdown<T>(
                      decoration: widget.dropdownDecoration,
                      onItemTap: _handleDropdownItemTap,
                      width: renderBoxSize.width,
                      items: _dropdownController.items,
                      searchEnabled: widget.searchEnabled,
                      dropdownItemDecoration: widget.dropdownItemDecoration,
                      itemBuilder: widget.itemBuilder,
                      itemSeparator: widget.itemSeparator,
                      searchDecoration: widget.searchDecoration,
                      searchController: widget.searchController,
                      maxSelections: widget.maxSelections,
                      singleSelect: widget.singleSelect,
                      onSearchChange: (value) async {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () async {
                          if (_dropdownController.isOpen) {
                            if (widget.future != null && widget.responsiveSearch) {
                              widget.onSearchChange?.call(value);
                              await handleFuture();
                            } else {
                              _dropdownController.setSearchQuery(value);
                            }
                          }
                        });
                      },
                      showOnTop: showOnTop,
                      noItemsFoundMessage: widget.noItemsFoundMessage,
                    ),
                  ),
                ),
              ],
            );
            return stack;
          },
          child: CompositedTransformTarget(
            link: _layerLink,
            child: ListenableBuilder(
              listenable: _listenable,
              builder: (_, __) {
                return InkWell(
                  mouseCursor: widget.enabled ? SystemMouseCursors.grab : SystemMouseCursors.forbidden,
                  onTap: widget.enabled ? _handleTap : null,
                  focusNode: _focusNode,
                  canRequestFocus: widget.enabled,
                  borderRadius: _getFieldBorderRadius(),
                  child: InputDecorator(
                    isEmpty: _dropdownController.selectedItems.isEmpty,
                    isFocused: _dropdownController.isOpen,
                    decoration: _buildDecoration(),
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildField(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleDropdownItemTap(DropdownItem<T> item) {
    if (widget.singleSelect) {
      _dropdownController._toggleOnly(item, toggleFiltered: widget.responsiveSearch);
    } else {
      if (widget.responsiveSearch) {
        _dropdownController._selectFiltered(item);
      } else {
        _dropdownController.toggleWhere((element) => element == item);
      }
    }
    _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);

    if (widget.singleSelect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeDropdown();
      });
    }
  }

  InputDecoration _buildDecoration() {
    final theme = Theme.of(context);

    final border = widget.fieldDecoration.border ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.fieldDecoration.borderRadius,
          ),
          borderSide: theme.inputDecorationTheme.border?.borderSide ?? const BorderSide(),
        );

    final fieldDecoration = widget.fieldDecoration;

    final prefixIcon = fieldDecoration.prefixIcon != null
        ? IconTheme.merge(
            data: IconThemeData(color: widget.enabled ? null : Colors.grey),
            child: fieldDecoration.prefixIcon!,
          )
        : null;

    return InputDecoration(
      enabled: widget.enabled,
      labelText: fieldDecoration.labelText,
      labelStyle: fieldDecoration.labelStyle,
      hintText: fieldDecoration.hintText,
      hintStyle: fieldDecoration.hintStyle,
      errorText: _formFieldKey.currentState?.errorText,
      filled: fieldDecoration.backgroundColor != null,
      fillColor: fieldDecoration.backgroundColor,
      border: fieldDecoration.border ?? border,
      enabledBorder: fieldDecoration.border ?? border,
      disabledBorder: fieldDecoration.disabledBorder,
      prefixIcon: prefixIcon,
      focusedBorder: fieldDecoration.focusedBorder ?? border,
      errorBorder: fieldDecoration.errorBorder,
      suffixIcon: _buildSuffixIcon(),
      contentPadding: fieldDecoration.padding,
    );
  }

  Widget? _buildSuffixIcon() {
    if (_loadingController.value) {
      return const CircularProgressIndicator.adaptive();
    }

    if (widget.fieldDecoration.showClearIcon && _dropdownController.selectedItems.isNotEmpty) {
      return GestureDetector(
        child: const Icon(Icons.clear),
        onTap: () {
          _dropdownController.clearAll();
          _dropdownController.setSearchQuery('');
          _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);
        },
      );
    }

    if (widget.fieldDecoration.suffixIcon == null) {
      return null;
    }

    if (!widget.fieldDecoration.animateSuffixIcon) {
      return widget.fieldDecoration.suffixIcon;
    }

    return AnimatedRotation(
      turns: _dropdownController.isOpen ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: widget.fieldDecoration.suffixIcon,
    );
  }

  Widget _buildField() {
    if (_dropdownController.selectedItems.isEmpty) {
      return const SizedBox();
    }

    final selectedOptions = _dropdownController.selectedItems;

    if (widget.singleSelect) {
      return Text(selectedOptions.first.label, style: widget.fieldDecoration.singleSelectItemStyle);
    }

    return _buildSelectedItems(selectedOptions);
  }

  /// Build the selected items for the dropdown.
  Widget _buildSelectedItems(List<DropdownItem<T>> selectedOptions) {
    final chipDecoration = widget.chipDecoration;

    if (widget.selectedItemBuilder != null) {
      return Wrap(
        spacing: chipDecoration.spacing,
        runSpacing: chipDecoration.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: selectedOptions.map((option) => widget.selectedItemBuilder!(option)).toList(),
      );
    }

    if (chipDecoration.wrap) {
      return Wrap(
        spacing: chipDecoration.spacing,
        runSpacing: chipDecoration.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: selectedOptions.map((option) => _buildChip(option, chipDecoration)).toList(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(double.infinity, 32)),
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: selectedOptions.length,
        itemBuilder: (context, index) {
          final option = selectedOptions[index];
          return _buildChip(option, chipDecoration);
        },
      ),
    );
  }

  Widget _buildChip(
    DropdownItem<dynamic> option,
    ChipDecoration chipDecoration,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: chipDecoration.borderRadius,
        color: widget.enabled ? chipDecoration.backgroundColor : Colors.grey.shade100,
        border: chipDecoration.border,
      ),
      padding: chipDecoration.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(option.label, style: chipDecoration.labelStyle),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              _dropdownController.unselectWhere((element) => element.label == option.label);
            },
            child: SizedBox(
              width: 16,
              height: 16,
              child: chipDecoration.deleteIcon ?? const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius? _getFieldBorderRadius() {
    if (widget.fieldDecoration.border is OutlineInputBorder) {
      return (widget.fieldDecoration.border! as OutlineInputBorder).borderRadius;
    }

    return BorderRadius.circular(widget.fieldDecoration.borderRadius);
  }

  void _handleTap() {
    if (!widget.enabled || _loadingController.value) {
      return;
    }

    if (_portalController.isShowing && _dropdownController.isOpen) return;

    if (widget.future != null) {
      if (widget.responsiveSearch && _dropdownController.selectedItems.isEmpty) {
        unawaited(handleFuture());
      }
    }

    _dropdownController.openDropdown();
  }

  void _handleOutsideTap() {
    if (!_dropdownController.isOpen) return;

    _closeDropdown();
  }

  void _closeDropdown() {
    if (widget.responsiveSearch) {
      _dropdownController.setItemsWhere((e) => e.selected);
    }
    _dropdownController.closeDropdown();
    widget.searchController?.clear();
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }
}
