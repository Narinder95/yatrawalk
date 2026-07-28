class JourneyModel {
  final String? id;

  final String startLocation;

  final String destinationName;
  final String destinationLocation;

  // Total pilgrimage distance
  final double totalDistanceKm;

  // Completed distance based on steps
  final double completedDistanceKm;

  final DateTime startDate;

  // User pledge
  final String sankalp;

  final bool completed;


  JourneyModel({
    this.id,

    required this.startLocation,

    required this.destinationName,
    required this.destinationLocation,

    required this.totalDistanceKm,

    this.completedDistanceKm = 0,

    required this.startDate,

    required this.sankalp,

    this.completed = false,
  });



  JourneyModel copyWith({

    String? id,

    String? startLocation,

    String? destinationName,

    String? destinationLocation,

    double? totalDistanceKm,

    double? completedDistanceKm,

    DateTime? startDate,

    String? sankalp,

    bool? completed,

  }) {

    return JourneyModel(

      id: id ?? this.id,

      startLocation:
          startLocation ?? this.startLocation,

      destinationName:
          destinationName ?? this.destinationName,

      destinationLocation:
          destinationLocation ?? this.destinationLocation,

      totalDistanceKm:
          totalDistanceKm ?? this.totalDistanceKm,

      completedDistanceKm:
          completedDistanceKm ?? this.completedDistanceKm,

      startDate:
          startDate ?? this.startDate,

      sankalp:
          sankalp ?? this.sankalp,

      completed:
          completed ?? this.completed,
    );
  }





  factory JourneyModel.fromJson(
      Map<String, dynamic> json) {

    return JourneyModel(

      id: json['id']?.toString(),

      startLocation:
          json['startLocation']?.toString() ?? "",


      destinationName:
          json['destinationName']?.toString() ?? "",


      destinationLocation:
          json['destinationLocation']?.toString() ?? "",


      totalDistanceKm:
          (json['totalDistanceKm'] as num?)
              ?.toDouble() ??
              0,


      completedDistanceKm:
          (json['completedDistanceKm'] as num?)
              ?.toDouble() ??
              0,


      startDate:
          DateTime.tryParse(
              json['startDate']?.toString() ?? "")
          ??
          DateTime.now(),


      sankalp:
          json['sankalp']?.toString() ?? "",


      completed:
          json['completed'] == true ||
          json['completed'] == "true",

    );
  }





  Map<String,dynamic> toJson(){

    return {

      "id": id,

      "startLocation": startLocation,

      "destinationName": destinationName,

      "destinationLocation": destinationLocation,

      "totalDistanceKm": totalDistanceKm,

      "completedDistanceKm": completedDistanceKm,

      "startDate":
          startDate.toIso8601String(),

      "sankalp": sankalp,

      "completed": completed,

    };

  }




  double get progressPercentage {

    if(totalDistanceKm == 0){
      return 0;
    }

    return
    (completedDistanceKm / totalDistanceKm)
        .clamp(0,1);

  }




  @override
  String toString(){

    return """
Journey:
From: $startLocation
To: $destinationName
Distance: $completedDistanceKm / $totalDistanceKm km
Sankalp: $sankalp
Completed: $completed
""";

  }

}