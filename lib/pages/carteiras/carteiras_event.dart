abstract class CarteirasEvent {}

class CarteirasLoadEvent extends CarteirasEvent {
  final bool forceRefresh;
  CarteirasLoadEvent({this.forceRefresh = false});
}

class CarteirasLoadMoreEvent extends CarteirasEvent {}

class CarteirasDeleteEvent extends CarteirasEvent {
  final String id;
  CarteirasDeleteEvent({required this.id});
}
