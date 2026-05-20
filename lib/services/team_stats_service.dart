import 'dart:convert';

import 'package:http/http.dart' as http;

class TeamStatsService {

  Future<void> fetchTeams() async {

    final url = Uri.parse(
      'https://dummyjson.com/users',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      print(data['users'][0]['firstName']);

    } else {

      print('ERROR: ${response.statusCode}');
    }
  }
}