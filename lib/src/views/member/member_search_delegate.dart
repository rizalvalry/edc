import 'package:app_dart/src/views/member/member_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../models/member.dart';

class MemberSearchDelegateCustom extends SearchDelegate<List<Member>> {
  TextEditingController _searchController = TextEditingController();

  final Future<List<Member>> members;

  MemberSearchDelegateCustom(this.members);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, []);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _searchController.text = query;

    return FutureBuilder<List<Member>>(
      future: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final searchResults = snapshot.data!.where((member) {
            final memberIdMatch =
                member.memberId.toLowerCase().contains(query.toLowerCase());
            final registrationIdMatch = member.registrationId
                .toLowerCase()
                .contains(query.toLowerCase());
            final registrationNameMatch = member.registrationName
                .toLowerCase()
                .contains(query.toLowerCase());
            final memberNameMatch =
                member.memberName.toLowerCase().contains(query.toLowerCase());
            return memberIdMatch ||
                registrationIdMatch ||
                registrationNameMatch ||
                memberNameMatch;
          }).toList();

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  // Arahkan pengguna ke halaman detail terlebih dahulu
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberDetailScreen(
                        memberId: searchResults[index].memberId,
                      ),
                    ),
                  );
                  // Menutup keyboard setelah pengguna sampai di halaman detail
                  FocusScope.of(context).unfocus();
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
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Buat sebuah FocusNode
    final FocusNode focusNode = FocusNode();
    return FutureBuilder<List<Member>>(
      future: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final suggestions = snapshot.data!.where((member) {
            final memberIdMatch =
                member.memberId.toLowerCase().contains(query.toLowerCase());
            final registrationIdMatch = member.registrationId
                .toLowerCase()
                .contains(query.toLowerCase());
            final registrationNameMatch = member.registrationName
                .toLowerCase()
                .contains(query.toLowerCase());
            final memberNameMatch =
                member.memberName.toLowerCase().contains(query.toLowerCase());
            return memberIdMatch ||
                registrationIdMatch ||
                registrationNameMatch ||
                memberNameMatch;
          }).toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(suggestions[index].memberName),
                subtitle: Text(suggestions[index].registrationName),
                onTap: () {
                  // Menutup keyboard
                  focusNode.unfocus();
                  // Arahkan pengguna ke halaman detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberDetailScreen(
                        memberId: suggestions[index].memberId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
