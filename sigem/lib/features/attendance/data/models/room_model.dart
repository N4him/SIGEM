class RoomModel {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final double allowedRadiusM;

  const RoomModel({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusM,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      allowedRadiusM: (json['allowed_radius_m'] ?? 50).toDouble(),
    );
  }
}