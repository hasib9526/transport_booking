import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../model/user_model.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = User().obs;

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    final response = await http.get(
      Uri.parse(
          'http://apps.bitopibd.com:8090/bimobapiv2/api/Account/GetUserInfoFroProductionApp'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      user.value = User.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(user.value.toJson()));
      Get.off(() => TransportBookingApp());
    } else {
      Get.snackbar(
        'Error',
        'Failed to login',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isLoading.value = false;
  }
}
