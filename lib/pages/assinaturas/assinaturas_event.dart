abstract class AssinaturasEvent {}

class AssinaturasLoadEvent extends AssinaturasEvent {
  final bool forceRefresh;
  AssinaturasLoadEvent({this.forceRefresh = false});
}

class AssinaturasLoadMoreEvent extends AssinaturasEvent {}
