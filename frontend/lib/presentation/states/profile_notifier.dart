import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends StateNotifier<Map<String, dynamic>?> {
  ProfileNotifier() : super(null);

  void setProfile(Map<String, dynamic> profile) {
    state = profile;
  }

  void updateProfile(Map<String, dynamic> updates) {
    if (state != null) {
      state = {...state!, ...updates};
    }
  }

  void clear() {
    state = null;
  }
}
