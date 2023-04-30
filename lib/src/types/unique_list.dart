import 'dart:collection';
import 'dart:math';

class UniqueList<T> implements List<T> {
  late final HashSet<int> _itemsHash;
  final List<T> _items;

  UniqueList([Iterable<T>? source])
      : _items = source == null ? <T>[] : List.of(source, growable: true) {
    _itemsHash = HashSet.from(_items.map((e) => e.hashCode));
    assert(_items.length == _itemsHash.length);
  }

  void _hashVerify() {
    final _listItemsHash = _items.map((e) => e.hashCode);
    if (_items.isEmpty != _itemsHash.isEmpty || !_listItemsHash.every(_itemsHash.contains)) {
      throw StateError("Found mismatched hashes between set and list.");
    }
  }

  void _hashRMGuard(dynamic rmItem) {
    final hashRM = _itemsHash.remove(rmItem.hashCode);
    if (!hashRM) {
      throw StateError("Unable ot remove original element's hash code.");
    }
  }

  @override
  set first(T element) {
    this[0] = element;
  }

  @override
  T get first => this[0];

  @override
  set last(T element) {
    this[_items.length - 1] = element;
  }

  @override
  T get last => this[_items.length - 1];

  @override
  set length(int newLength) => _items.length = newLength;

  @override
  int get length => _items.length;

  @override
  UniqueList<T> operator +(List<T> other) {
    return UniqueList(this)..addAll(other);
  }

  @override
  T operator [](int index) => _items[index];

  @override
  void operator []=(int index, T value) {
    _hashRMGuard(_items[index]);
    _itemsHash.add(value.hashCode);
    _items[index] = value;
    _hashVerify();
  }

  @override
  void add(T element) {
    if (!_itemsHash.contains(element.hashCode)) {
      _items.add(element);
      _itemsHash.add(element.hashCode);
    }
  }

  @override
  void addAll(Iterable<T> iterable) {
    iterable.forEach(this.add);
  }

  @override
  bool any(bool Function(T element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Map<int, T> asMap() {
    // TODO: implement asMap
    throw UnimplementedError();
  }

  @override
  List<R> cast<R>() {
    return _items.cast<R>();
  }

  @override
  void clear() {
    _items.clear();
    _itemsHash.clear();
    _hashVerify();
  }

  @override
  bool contains(Object? element) {
    return _items.contains(element);
  }

  @override
  T elementAt(int index) {
    return _items[index];
  }

  @override
  bool every(bool Function(T element) test) {
    return _items.every(test);
  }

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) toElements) {
    return _items.expand<E>(toElements);
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    // TODO: implement fillRange
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  F fold<F>(F initialValue, F Function(F previousValue, T element) combine) {
    return _items.fold<F>(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(T element) action) {
    // TODO: implement forEach
  }

  @override
  Iterable<T> getRange(int start, int end) {
    // TODO: implement getRange
    throw UnimplementedError();
  }

  @override
  int indexOf(T element, [int start = 0]) {
    // TODO: implement indexOf
    throw UnimplementedError();
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    // TODO: implement indexWhere
    throw UnimplementedError();
  }

  @override
  void insert(int index, T element) {
    // TODO: implement insert
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    // TODO: implement insertAll
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement iterator
  Iterator<T> get iterator => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    // TODO: implement lastIndexOf
    throw UnimplementedError();
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    // TODO: implement lastIndexWhere
    throw UnimplementedError();
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  Iterable<M> map<M>(M Function(T e) toElement) {
    return _items.map<M>(toElement);
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  bool remove(Object? element) {
    _hashRMGuard(element);
    return _items.remove(element);
  }

  @override
  T removeAt(int index) {
    // TODO: implement removeAt
    throw UnimplementedError();
  }

  @override
  T removeLast() {
    // TODO: implement removeLast
    throw UnimplementedError();
  }

  @override
  void removeRange(int start, int end) {
    // TODO: implement removeRange
  }

  @override
  void removeWhere(bool Function(T element) test) {
    // TODO: implement removeWhere
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    // TODO: implement replaceRange
  }

  @override
  void retainWhere(bool Function(T element) test) {
    // TODO: implement retainWhere
  }

  @override
  // TODO: implement reversed
  Iterable<T> get reversed => throw UnimplementedError();

  @override
  void setAll(int index, Iterable<T> iterable) {
    // TODO: implement setAll
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    // TODO: implement setRange
  }

  @override
  void shuffle([Random? random]) {
    // TODO: implement shuffle
  }

  @override
  // TODO: implement single
  T get single => throw UnimplementedError();

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    // TODO: implement sort
  }

  @override
  List<T> sublist(int start, [int? end]) {
    // TODO: implement sublist
    throw UnimplementedError();
  }

  @override
  Iterable<T> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<T> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Set<T> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<Y> whereType<Y>() {
    return _items.whereType<Y>();
  }

}
