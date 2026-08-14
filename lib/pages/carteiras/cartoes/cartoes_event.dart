abstract class CartoesEvent {}

class CartoesLoadEvent extends CartoesEvent {
  final bool forceRefresh;
  CartoesLoadEvent({this.forceRefresh = false});
}

class CartoesLoadMoreEvent extends CartoesEvent {}
