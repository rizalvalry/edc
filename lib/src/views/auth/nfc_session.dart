// ignore_for_file: unused_field, use_build_context_synchronously, curly_braces_in_flow_control_structures, unnecessary_string_interpolations

import 'dart:io';

import 'package:app_dart/src/config/app_color.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

Future<void> startSession({
  required BuildContext context,
  required Future<String?> Function(NfcTag) handleTag,
  String alertMessage = 'Tempelkan Kartu pada Perangkat NFC',
}) async {
  if (!(await NfcManager.instance.isAvailable()))
    return showDialog(
      context: context,
      builder: (context) => _UnavailableDialog(),
    );

  if (Platform.isAndroid)
    return showDialog(
      context: context,
      builder: (context) => _AndroidSessionDialog("$alertMessage", handleTag),
    );

  if (Platform.isIOS)
    return NfcManager.instance.startSession(
      alertMessage: alertMessage,
      onDiscovered: (tag) async {
        try {
          final result = await handleTag(tag);
          if (result == null) return;
          await NfcManager.instance.stopSession(alertMessage: result);
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: '$e');
        }
      },
    );

  throw ('unsupported platform: ${Platform.operatingSystem}');
}

class _UnavailableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: const Text(
          'NFC may not be supported or may be temporarily turned off.'),
      actions: [
        TextButton(
          child: const Text('GOT IT'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final Future<String?> Function(NfcTag tag) handleTag;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;

  String? _errorMessage;
  bool _showFlareAnimation = false; // Tambahkan variabel ini
  bool _isNFCScanning = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        try {
          setState(() => _isNFCScanning = true);
          final result = await widget.handleTag(tag);
          if (result == null) return;
          await NfcManager.instance.stopSession();
          setState(() => _alertMessage = result);
        } catch (e) {
          await NfcManager.instance.stopSession().catchError((_) {/* no op */});
          setState(() => _errorMessage = '$e');
        } finally {
          setState(() => _isNFCScanning = false);
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) {/* no op */});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNFCScanning) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.darkOrange,
        ), // Tampilkan indikator loading
      );
    }
    return AlertDialog(
      backgroundColor: AppColor.baseColor,
      contentTextStyle: TextStyle(color: Colors.white),
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? 'Error'
            : _alertMessage?.isNotEmpty == true
                ? 'NFC Done'
                : 'Aktivasi UID',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage?.isNotEmpty == true
                ? _errorMessage!
                : _alertMessage?.isNotEmpty == true
                    ? _alertMessage!
                    : widget.alertMessage,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            _errorMessage?.isNotEmpty == true
                ? 'GOT IT'
                : _alertMessage?.isNotEmpty == true
                    ? 'OK'
                    : 'CANCEL',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => {
            Navigator.of(context).pop(),
          },
        ),
      ],
    );
  }
}
