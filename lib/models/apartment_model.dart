class ApartmentModel {
  final String id;
  final String ownerId;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  final double price;
  final String description;
  final List<String> images;
  
  // House rules
  final bool allowsSmoking;
  final bool allowsPets;
  final bool allowsAlcohol;
  final bool quietHours;
  final bool ownLaundry;
  
  // Included expenses
  final bool includesWater;
  final bool includesElectricity;
  final bool includesInternet;
  final bool includesGas;
  
  final DateTime createdAt;

  ApartmentModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    required this.price,
    required this.description,
    required this.images,
    this.allowsSmoking = false,
    this.allowsPets = false,
    this.allowsAlcohol = false,
    this.quietHours = false,
    this.ownLaundry = false,
    this.includesWater = false,
    this.includesElectricity = false,
    this.includesInternet = false,
    this.includesGas = false,
    required this.createdAt,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    return ApartmentModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      allowsSmoking: json['allows_smoking'] as bool? ?? false,
      allowsPets: json['allows_pets'] as bool? ?? false,
      allowsAlcohol: json['allows_alcohol'] as bool? ?? false,
      quietHours: json['quiet_hours'] as bool? ?? false,
      ownLaundry: json['own_laundry'] as bool? ?? false,
      includesWater: json['includes_water'] as bool? ?? false,
      includesElectricity: json['includes_electricity'] as bool? ?? false,
      includesInternet: json['includes_internet'] as bool? ?? false,
      includesGas: json['includes_gas'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'description': description,
      'images': images,
      'allows_smoking': allowsSmoking,
      'allows_pets': allowsPets,
      'allows_alcohol': allowsAlcohol,
      'quiet_hours': quietHours,
      'own_laundry': ownLaundry,
      'includes_water': includesWater,
      'includes_electricity': includesElectricity,
      'includes_internet': includesInternet,
      'includes_gas': includesGas,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
