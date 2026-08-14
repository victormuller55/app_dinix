abstract class ReceitasEvent {}

class ReceitasLoadEvent extends ReceitasEvent {
  final bool forceRefresh;
  ReceitasLoadEvent({this.forceRefresh = false});
}

class ReceitasLoadMoreEvent extends ReceitasEvent {}
