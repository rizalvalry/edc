import 'dart:typed_data';

import 'package:app_dart/src/models/record.dart';
import 'package:app_dart/src/config/my_utils.dart';
import 'package:app_dart/src/models/record.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NdefRecordPage extends StatelessWidget {
  NdefRecordPage(this.index, this.record);

  void someFunction(Uint8List uint8List) {
    String hexString = uint8ListToHexString(uint8List);
    // Sekarang Anda dapat menggunakan hexString.
    // ...
  }

  final int index;

  final NdefRecord record;

  @override
  Widget build(BuildContext context) {
    final info = NdefRecordInfo.fromNdef(record);
    return Scaffold(
      appBar: AppBar(
        title: Text('Record #$index'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          _RecordColumn(
            title: Text('${info.title}'),
            subtitle: Text('${info.subtitle}'),
          ),
          SizedBox(height: 12),
          _RecordColumn(
            title: Text('Size'),
            subtitle: Text('${record.byteLength} bytes'),
          ),
          SizedBox(height: 12),
          // _RecordColumn(
          //   title: Text('Type Name Format'),
          //   subtitle: Text('${uint8ListToHexString(record.typeNameFormat.index)}'),
          // ),
          SizedBox(height: 12),
          _RecordColumn(
            title: Text('Type'),
            subtitle: Text(uint8ListToHexString(record.type)),
          ),
          SizedBox(height: 12),
          _RecordColumn(
            title: Text('Identifier'),
            subtitle: Text(uint8ListToHexString(record.identifier)),
          ),
          SizedBox(height: 12),
          _RecordColumn(
            title: Text('Payload'),
            subtitle: Text(uint8ListToHexString(record.payload)),
          ),
        ],
      ),
    );
  }
}

class _RecordColumn extends StatelessWidget {
  _RecordColumn({required this.title, required this.subtitle});

  final Widget title;

  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
          child: title,
        ),
        SizedBox(height: 2),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 15),
          child: subtitle,
        ),
      ],
    );
  }
}

class NdefRecordInfo {
  const NdefRecordInfo(
      {required this.record, required this.title, required this.subtitle});

  final Record record;

  final String title;

  final String subtitle;

  static NdefRecordInfo fromNdef(NdefRecord record) {
    final _record = Record.fromNdef(record);
    if (_record is WellknownTextRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Text',
        subtitle: '(${_record.languageCode}) ${_record.text}',
      );
    if (_record is WellknownUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Uri',
        subtitle: '${_record.uri}',
      );
    if (_record is MimeRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Mime',
        subtitle: '(${_record.type}) ${_record.dataString}',
      );
    if (_record is AbsoluteUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Absolute Uri',
        subtitle: '(${_record.uriType}) ${_record.payloadString}',
      );
    if (_record is ExternalRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'External',
        subtitle: '(${_record.domainType}) ${_record.dataString}',
      );
    if (_record is UnsupportedRecord) {
      // more custom info from NdefRecord.
      if (record.typeNameFormat == NdefTypeNameFormat.empty)
        return NdefRecordInfo(
          record: _record,
          title: _typeNameFormatToString(_record.record.typeNameFormat),
          subtitle: '-',
        );
      return NdefRecordInfo(
        record: _record,
        title: _typeNameFormatToString(_record.record.typeNameFormat),
        subtitle:
            '(${uint8ListToHexString(_record.record.type)}) ${uint8ListToHexString(_record.record.payload)}',
      );
    }
    throw UnimplementedError();
  }
}

String _typeNameFormatToString(NdefTypeNameFormat format) {
  switch (format) {
    case NdefTypeNameFormat.empty:
      return 'Empty';
    case NdefTypeNameFormat.nfcWellknown:
      return 'NFC Wellknown';
    case NdefTypeNameFormat.media:
      return 'Media';
    case NdefTypeNameFormat.absoluteUri:
      return 'Absolute Uri';
    case NdefTypeNameFormat.nfcExternal:
      return 'NFC External';
    case NdefTypeNameFormat.unknown:
      return 'Unknown';
    case NdefTypeNameFormat.unchanged:
      return 'Unchanged';
  }
}
