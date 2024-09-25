part of '../multi_dropdown.dart';

/// Controller for the multiselect dropdown.
class MultiSelectController<T> extends ChangeNotifier {
  /// a flag to indicate whether the controller is initialized.
  bool _initialized = false;

  /// set initialized flag to true.
  void _initialize() {
    _initialized = true;
  }

  List<DropdownItem<T>> _items = [];

  List<DropdownItem<T>> _filteredItems = [];

  String _searchQuery = '';

  /// Gets the list of dropdown items.
  List<DropdownItem<T>> get items => _searchQuery.isEmpty ? _items : _filteredItems;

  /// Gets the list of selected dropdown items.
  List<DropdownItem<T>> get selectedItems => _items.where((element) => element.selected).toList();

  /// Gets the list of disabled dropdown items.
  List<DropdownItem<T>> get disabledItems => _items.where((element) => element.disabled).toList();

  bool _open = false;

  /// Gets whether the dropdown is open.
  bool get isOpen => _open;

  bool _isDisposed = false;

  /// Gets whether the controller is disposed.
  bool get isDisposed => _isDisposed;

  /// on selection changed callback invoker.
  OnSelectionChanged<DropdownItem<T>>? _onSelectionChanged;

  /// on search changed callback invoker.
  OnSearchChanged? _onSearchChanged;

  /// sets the list of dropdown items.
  /// It replaces the existing list of dropdown items.
  void setItems(
    List<DropdownItem<T>> options, {
    bool setFilteredItems = false,
    bool notify = true,
  }) {
    _items
      ..clear()
      ..addAll(options);

    if (setFilteredItems) {
      _filteredItems = List.from(_items);
    }

    if (notify) {
      notifyListeners();
      _onSelectionChanged?.call(selectedItems);
    }
  }

  void setItemsWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items.where((element) => predicate(element)).toList();
  }

  /// sets the list of dropdown items.
  /// It keep the selected items, and changes the filtered items
  /// It's used in dropdown future mode
  void setItemsKeepingSelecteds(List<DropdownItem<T>> options) {
    _filteredItems
      ..clear()
      ..addAll(options);

    for (final filteredItem in _filteredItems) {
      final item = _items.firstWhereOrNull((e) => e.value == filteredItem.value);
      if (item != null) {
        filteredItem.selected = item.selected;
      }
    }

    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// Adds a dropdown item to the list of dropdown items.
  /// The [index] parameter is optional, and if provided, the item will be inserted at the specified index.
  void addItem(DropdownItem<T> option, {int index = -1}) {
    if (index == -1) {
      _items.add(option);
    } else {
      _items.insert(index, option);
    }
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// Adds a list of dropdown items to the list of dropdown items.
  void addItems(List<DropdownItem<T>> options) {
    _items.addAll(options);
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// clears all the selected items.
  void clearAll() {
    _items = _items
        .map(
          (element) => element.selected ? element.copyWith(selected: false) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// selects all the items.
  void selectAll() {
    _items = _items
        .map(
          (element) => !element.selected ? element.copyWith(selected: true) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// select the item at the specified index.
  ///
  /// The [index] parameter is the index of the item to select.
  void selectAtIndex(int index) {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    if (item.disabled || item.selected) return;

    selectWhere((element) => element == _items[index]);
  }

  /// deselects all the items.
  void toggleWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) ? element.copyWith(selected: !element.selected) : element,
        )
        .toList();
    if (_searchQuery.isNotEmpty) {
      _filteredItems = _items
          .where(
            (item) => item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// Changes the selected items
  void _selectFiltered(DropdownItem<T> item) {
    final index = _items.indexWhere((e) => e.value == item.value);
    if (index > -1) {
      _items.removeAt(index);
    } else {
      _items.add(item.copyWith(selected: true));
    }

    final filteredIndex = _filteredItems.indexWhere((e) => e.value == item.value);
    if (filteredIndex > -1) {
      _filteredItems[filteredIndex].selected = !_filteredItems[filteredIndex].selected;
    }

    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// selects the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void selectWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && !element.selected ? element.copyWith(selected: true) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  void _toggleOnly(DropdownItem<T> item, {bool toggleFiltered = false}) {
    _items = _items
        .map(
          (element) => element == item ? element.copyWith(selected: !element.selected) : element.copyWith(selected: false),
        )
        .toList();

    if (toggleFiltered) {
      _filteredItems = _filteredItems
          .map(
            (element) => element == item ? element.copyWith(selected: !element.selected) : element.copyWith(selected: false),
          )
          .toList();
    }

    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// unselects the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void unselectWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && element.selected ? element.copyWith(selected: false) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// disables the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  void disableWhere(bool Function(DropdownItem<T> item) predicate) {
    _items = _items
        .map(
          (element) => predicate(element) && !element.disabled ? element.copyWith(disabled: true) : element,
        )
        .toList();
    notifyListeners();
    _onSelectionChanged?.call(selectedItems);
  }

  /// shows the dropdown, if it is not already open.
  void openDropdown() {
    if (_open) return;

    _open = true;
    notifyListeners();
  }

  /// hides the dropdown, if it is not already closed.
  void closeDropdown() {
    if (!_open) return;

    _open = false;
    notifyListeners();
  }

  // ignore: use_setters_to_change_properties
  void _setOnSelectionChange(OnSelectionChanged<DropdownItem<T>>? onSelectionChanged) {
    this._onSelectionChanged = onSelectionChanged;
  }

  // ignore: use_setters_to_change_properties
  void _setOnSearchChange(OnSearchChanged? onSearchChanged) {
    this._onSearchChanged = onSearchChanged;
  }

  /// sets the search query.
  // The [query] parameter is the search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      _filteredItems = _items
          .where(
            (item) => item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    _onSearchChanged?.call(query);
    notifyListeners();
  }

  // clears the search query.
  void _clearSearchQuery({bool notify = false}) {
    _searchQuery = '';
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    super.dispose();
    _isDisposed = true;
  }

  @override
  String toString() {
    return 'MultiSelectController(options: $_items, open: $_open)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MultiSelectController<T> && listEquals(other._items, _items) && other._open == _open;
  }

  @override
  int get hashCode => _items.hashCode ^ _open.hashCode;
}
