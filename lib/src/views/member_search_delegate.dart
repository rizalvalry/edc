import 'package:app_dart/src/models/member_detail.dart';
import 'package:app_dart/src/views/member_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberSearchDelegateCustom extends SearchDelegate<List<Member>> {
  final Future<List<Member>> members;

  MemberSearchDelegateCustom(this.members);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final searchResults = snapshot.data!
              .where((member) =>
                  member.memberName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  member.memberId.toString().contains(query))
              .toList();

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberDetailScreen(
                        memberId: searchResults[index].memberId,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(searchResults[index].memberName),
                  subtitle: Text(searchResults[index].registrationName),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final suggestions = snapshot.data!
              .where((member) =>
                  member.memberName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  member.memberId.toString().contains(query))
              .toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestions[index].memberName),
                subtitle: Text(suggestions[index].registrationName),
                onTap: () {
                  query = suggestions[index].memberName;
                  showResults(context);
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
