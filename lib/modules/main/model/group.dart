class Group {
  final String? id;
  final String name;

  Group({
    this.id,
    required this.name,
  });

  static Group fromJson(Map<String, dynamic> json) {
    return Group(
      name: json["name"],
    );
  }
}


// {
//   "name": "Family 1",
//   "members": {
//     "member1": {
//       "displayName": "Magda",
//     }
//   },
//   "nr": 1,
// }
