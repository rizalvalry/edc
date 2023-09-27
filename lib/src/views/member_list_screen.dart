import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/views/member/member_add.dart';
import 'package:app_dart/src/views/member_detail_screen.dart';
import 'package:app_dart/src/views/member_search_delegate.dart';
import 'package:app_dart/src/views/settlement/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/member.dart';
import '../controllers/member_controller.dart';

// Buat class MemberSearchDelegateCustom seperti yang sudah Anda miliki

class MemberListScreen extends StatelessWidget {
  final MemberController _controller = MemberController();
  Future<List<Member>> members;
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
    try {
      final newMembers = await _controller.fetchMembers(
        sort: currentSort,
        dir: 'ASC',
      );

      // Memperbarui state `members` dengan data yang baru
      members = Future.value(newMembers);
    } catch (error) {
      // Handle kesalahan jika diperlukan
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        height: 50,
        child: FittedBox(
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MemberAdd()), // Ganti dengan nama halaman Settlement yang sesuai
              );
            },
            backgroundColor: AppColor.darkOrange,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppConfiguration.bottomNavigationBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MemberListScreen(
                                members: MemberController().fetchMembers(
                                    sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                                currentSort: 'ASC',
                              )));
                },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        color: AppColor.darkOrange,
                        size: 20,
                      ),
                      Text(
                        'Home',
                        style:
                            TextStyle(color: AppColor.darkOrange, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SettlementScreen()), // Ganti dengan nama halaman Settlement yang sesuai
                  );
                },
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.wallet,
                        color: AppColor.darkOrange,
                        size: 20,
                      ),
                      Text(
                        'Settlement',
                        style:
                            TextStyle(color: AppColor.darkOrange, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        // toolbarHeight: ,
        shape: ShapeBorder.lerp(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          null,
          0,
        ),
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
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // Mengatur sudut melengkung
                        ),
                        shadowColor: AppColor.baseColor,
                        child: ListTile(
                          title: Text(membersData[index].memberName),
                          subtitle: Text(membersData[index].registrationName),
                        ),
                      ),
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
