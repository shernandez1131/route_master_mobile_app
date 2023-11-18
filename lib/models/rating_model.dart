import 'package:route_master_mobile_app/models/trip_detail_model.dart';

class Rating {
  final int? ratingId;
  final int value;
  final String? comment;
  final int passengerId;
  final int tripDetailId;
  final TripDetail? tripDetail;

  Rating({
    this.ratingId,
    required this.value,
    this.comment,
    required this.passengerId,
    required this.tripDetailId,
    this.tripDetail,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      ratingId: json['ratingId'],
      value: json['value'],
      comment: json['comment'],
      passengerId: json['passengerId'],
      tripDetailId: json['tripDetailId'],
      //tripDetail: TripDetail.fromJson(json['tripDetail']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ratingId': ratingId,
        'value': value,
        'comment': comment,
        'passengerId': passengerId,
        'tripDetailId': tripDetailId
      };
}
