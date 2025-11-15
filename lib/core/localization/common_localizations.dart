import 'package:flutter/material.dart';

class CommonLocalizations {
  final Locale locale;

  CommonLocalizations(this.locale);

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'Attendance App',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'update': 'Update',
      'submit': 'Submit',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'optional': 'Optional',
      'required': 'Required',
    },
    'vi': {
      'app_name': 'Ứng dụng Chấm công',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'confirm': 'Xác nhận',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'create': 'Tạo',
      'update': 'Cập nhật',
      'submit': 'Gửi',
      'back': 'Quay lại',
      'next': 'Tiếp',
      'done': 'Xong',
      'ok': 'OK',
      'yes': 'Có',
      'no': 'Không',
      'search': 'Tìm kiếm',
      'filter': 'Lọc',
      'sort': 'Sắp xếp',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'success': 'Thành công',
      'retry': 'Thử lại',
      'optional': 'Tùy chọn',
      'required': 'Bắt buộc',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get create => translate('create');
  String get update => translate('update');
  String get submit => translate('submit');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');
  String get optional => translate('optional');
  String get required => translate('required');
}
