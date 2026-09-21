import 'package:equatable/equatable.dart';

/// An optional price bound pair for filtering search results.
///
/// An unset bound is meant to be omitted from the query string rather than
/// sent as `0`; validation of an inverted range is left to the caller.
class PriceRange extends Equatable {
  const PriceRange({this.min, this.max});

  static const none = PriceRange();

  final double? min;
  final double? max;

  bool get isEmpty => min == null && max == null;

  bool get isInverted => min != null && max != null && min! > max!;

  @override
  List<Object?> get props => [min, max];
}
