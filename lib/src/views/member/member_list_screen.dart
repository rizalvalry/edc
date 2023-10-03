// ignore_for_file: must_be_immutable

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/views/content/drawer.dart';
import 'package:app_dart/src/views/member/member_add.dart';
import 'package:app_dart/src/views/member/member_detail_screen.dart';
import 'package:app_dart/src/views/member/member_search_delegate.dart';
import 'package:app_dart/src/views/settlement/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/member.dart';
import '../../controllers/member_controller.dart';

import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/foundation.dart';

class MemberListScreen extends StatelessWidget {
  final MemberController _controller = MemberController();
  Future<List<Member>> members;
  final String currentSort;

  MemberListScreen({
    required this.members,
    required this.currentSort,
  });

  void showMemberSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: MemberSearchDelegateCustom(members),
    );
  }

  void toggleSort(BuildContext context) {
    // Implementasikan logika perubahan urutan di sini jika diperlukan.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: AppColor.baseColor,
          statusBarColor: AppColor.baseColor,
        ),
        title: const Text(
          'Daftar Member',
          style: TextStyle(color: AppColor.darkOrange),
        ),
        backgroundColor: AppColor.baseColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColor.darkOrange,
            ),
            onPressed: () {
              showMemberSearch(context);
            },
          ),
        ],
      ),
      drawer: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: CustomDrawer()),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.5,
      body: FutureBuilder<List<Member>>(
        future: members,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final memberList = snapshot.data ?? [];
            return AlphabeticScrollPage(
              memberList: memberList.map((member) {
                final title = member.memberName;
                final memberId = member.memberId;
                final tag = title.isNotEmpty ? title[0].toUpperCase() : 'N/A';
                return azItem(title: title, tag: tag, memberId: memberId);
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: SizedBox(
        height: 50,
        child: FittedBox(
          child: FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberAdd(),
                ),
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
          borderRadius: const BorderRadius.only(
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
                        members: MemberController()
                            .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                        currentSort: 'ASC',
                      ),
                    ),
                  );
                },
                child: Container(
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        color: AppColor.darkOrange,
                        size: 20,
                      ),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: AppColor.darkOrange,
                          fontSize: 10,
                        ),
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
                      builder: (context) => SettlementScreen(),
                    ),
                  );
                },
                child: Container(
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.wallet,
                        color: AppColor.darkOrange,
                        size: 20,
                      ),
                      Text(
                        'Settlement',
                        style: TextStyle(
                          color: AppColor.darkOrange,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class azItem extends ISuspensionBean {
  final String title;
  final String tag;
  final String memberId;

  azItem({
    required this.title,
    required this.tag,
    required this.memberId,
  });

  @override
  String getSuspensionTag() => tag;
}

class AlphabeticScrollPage extends StatefulWidget {
  final List<azItem> memberList;
  const AlphabeticScrollPage({Key? key, required this.memberList})
      : super(key: key);

  @override
  State<AlphabeticScrollPage> createState() => _AlphabeticScrollPageState();
}

class _AlphabeticScrollPageState extends State<AlphabeticScrollPage> {
  @override
  Widget build(BuildContext context) {
    return AzListView(
      data: widget.memberList,
      itemCount: widget.memberList.length,
      itemBuilder: (context, index) {
        final member = widget.memberList[index];
        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberDetailScreen(
                  memberId: widget.memberList[index].memberId, // Ubah ini
                ),
              ),
            );

            if (result == true) {
              // Perbarui data atau state yang diperlukan di sini jika diperlukan.
            }
          },
          child: ListTile(
            title: Text(member
                .title), // Ubah dari member.memberName menjadi member.title
          ),
        );
      },
    );
  }
}
