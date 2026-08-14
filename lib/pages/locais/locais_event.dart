abstract class LocaisEvent {}

class LocaisLoadEvent extends LocaisEvent {
  final bool forceRefresh;
  LocaisLoadEvent({this.forceRefresh = false});
}

class LocaisLoadMoreEvent extends LocaisEvent {}
