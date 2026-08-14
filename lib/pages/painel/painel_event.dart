abstract class PainelEvent {}

class PainelLoadEvent extends PainelEvent {
  final bool forceRefresh;
  PainelLoadEvent({this.forceRefresh = false});
}
