import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/views/member_detail_screen.dart';
import 'package:app_dart/src/views/member_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/member.dart';
import '../controllers/member_controller.dart';

// Buat class MemberSearchDelegateCustom seperti yang sudah Anda miliki

class MemberListScreen extends StatelessWidget {
  final MemberController _controller = MemberController();
  final Future<List<Member>> members;
  final String currentSort;

  MemberListScreen({
    required this.members,
    required this.currentSort,
  });

  void toggleSort(BuildContext context) {
    // Fungsi untuk memanggil perubahan urutan di parent widget
    // (Anda perlu mengimplementasikan ini di parent widget)
  }

  void showMemberSearch(BuildContext context) {
    // Fungsi untuk menampilkan kotak pencarian
    showSearch(
      context: context,
      delegate: MemberSearchDelegateCustom(members),
    );
  }

  Future<void> loadMembers(BuildContext context) async {
    // Fungsi untuk memuat ulang daftar anggota di parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: AppColor.baseColor,
          statusBarColor: AppColor.baseColor,
        ),
        title: Text(
          'Daftar Member',
          style: TextStyle(color: AppColor.darkOrange),
        ),
        backgroundColor: AppColor.baseColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppColor.darkOrange,
            ),
            onPressed: () {
              showMemberSearch(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.sort, color: AppColor.darkOrange),
            onPressed: () {
              toggleSort(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return loadMembers(context);
        },
        child: FutureBuilder<List<Member>>(
          future: members,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              final membersData = snapshot.data!;
              return ListView.builder(
                itemCount: membersData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailScreen(
                            memberId: membersData[index].memberId,
                          ),
                        ),
                      );

                      if (result == true) {
                        // Perbarui data atau state yang diperlukan di sini
                        loadMembers(context);
                      }
                    },
                    child: ListTile(
                      title: Text(membersData[index].memberName),
                      subtitle: Text(membersData[index].registrationName),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: Text('Tidak ada data ditemukan.'),
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MemberListScreen(
      members:
          MemberController().fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
      currentSort: 'ASC',
    ),
  ));
}
