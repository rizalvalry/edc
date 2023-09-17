import 'dart:convert';
import 'package:app_dart/src/models/member.dart';
import 'package:app_dart/src/models/member_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MemberController {
  Future<List<Member>> fetchMembers(
      {String sort = 'LEVE_REGISTRATIONNAME', String dir = 'ASC'}) async {
    final Uri uri = Uri.parse(
      'https://wartelsus.mitrakitajaya.com/members/memberslistmobile'
      '?_dc=1694400095666'
      '&branchID=10'
      '&filter_status=1'
      // '&filter_textSearch='
      // '&page=1'
      '&start=0'
      // '&limit=1'
      '&sort=$sort'
      '&dir=$dir',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['results'];
      return jsonResponse.map((data) => Member.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<MemberDetail> fetchMemberDetail(String memberId) async {
    final response = await http.post(
      Uri.parse('https://wartelsus.mitrakitajaya.com/members/properties'),
      body: {
        'membersid': memberId,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return MemberDetail.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load member detail');
    }
  }

  String getImageUrl(String memberId) {
    return '$memberId';
  }

  Future<Widget> loadImage(String memberId) async {
    final http.Client httpClient = http.Client();
    final imageUrl = 'https://wartelsus.mitrakitajaya.com/resources/members/CAPTURE$memberId.png';

    print(imageUrl);

    try {
      final response = await httpClient.head(Uri.parse(imageUrl));
      if (response.statusCode == 404) {
        return ClipOval(
          child: Image.asset(
            'assets/images/no-photos.png',
            fit: BoxFit.cover,
            height: 100,
            width: 100,
          ),
        );
      } else {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        );
      }
    } catch (e) {
      print('Error loading image: $e');
      return Container();
    } finally {
      httpClient.close();
    }
  }
}
