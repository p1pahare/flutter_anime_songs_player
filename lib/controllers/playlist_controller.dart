import 'dart:async';
import 'dart:developer';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/models/login_models.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/repositories/playlists_repo.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum LoginMode {
  loading,
  failed,
  loggedIn,
  login,
  register,
  forgotPassword,
  changePassword,
  updateUserDetails
}

class PlaylistController extends GetxController {
  AnimeThemeRepository networkCalls = AnimeThemeRepository();
  final PlaylistRepo playlistRepo = PlaylistRepo();
  final RxBool wait = false.obs;
  final RxString toastMessage = "".obs;
  GetStorage box = GetStorage();
  RxList<AudioEntry> listings = RxList.empty();
  RxStatus status = RxStatus.empty();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rxn<LoginMode> mode = Rxn(LoginMode.loading);
  ScrollController scroll = ScrollController();
  final usernameTec = TextEditingController();
  final emailTec = TextEditingController();
  final oldPasswordTec = TextEditingController();
  final passwordTec = TextEditingController();
  final confirmPassTec = TextEditingController();
  RxBool agree = false.obs;
  RxBool rememberMe = false.obs;

  void setRememberMe(bool? rememberMe) {
    this.rememberMe.value = rememberMe ?? true;
    update();
  }

  void setAgree(bool? agree) {
    this.agree.value = agree ?? true;
    update();
  }

  bool showEmail() =>
      mode.value == LoginMode.login ||
      mode.value == LoginMode.register ||
      mode.value == LoginMode.forgotPassword;

  bool showPassoword() =>
      mode.value == LoginMode.login || mode.value == LoginMode.register;

  bool showCPassoword() => mode.value == LoginMode.register;

  bool showAgree() => mode.value == LoginMode.register;

  bool showUsername() => mode.value == LoginMode.register;

  bool showRemember() => mode.value == LoginMode.login;

  bool showOldPassword() => mode.value == LoginMode.changePassword;

  Future setMode(LoginMode loginMode) async {
    mode.value = loginMode;
    toastMessage.value = "";
    formKey.currentState?.reset();
    await Future.delayed(const Duration(milliseconds: 500));
    update();
  }

  String getTitle() {
    if (mode.value == LoginMode.login) {
      return Values.loginNote;
    }
    if (mode.value == LoginMode.forgotPassword) {
      return Values.forgotNote;
    }
    if (mode.value == LoginMode.register) {
      return Values.registerNote;
    }
    return "";
  }

  String? unifiedValidator(String? field) {
    log(field.toString());
    switch (mode.value) {
      case LoginMode.loggedIn:
        return null;
      case LoginMode.login:
        if (field == Values.enterEmail) {
          return isValidEmail(emailTec.text);
        } else if (field == Values.enterPassword) {
          if (isValidEmail(emailTec.text) != null) return null;
          return isValidPassword(passwordTec.text);
        } else {
          return null;
        }
      case LoginMode.register:
        if (field == Values.enterUsername) {
          return isValidUsername(usernameTec.text);
        } else if (field == Values.enterEmail) {
          if (isValidUsername(usernameTec.text) != null) return null;
          return isValidEmail(emailTec.text);
        } else if (field == Values.enterPassword) {
          if (isValidUsername(usernameTec.text) != null ||
              isValidEmail(emailTec.text) != null) return null;
          return isValidPassword(passwordTec.text);
        } else if (field == Values.reenterPassword) {
          if (isValidUsername(usernameTec.text) != null ||
              isValidEmail(emailTec.text) != null ||
              isValidPassword(passwordTec.text) != null) return null;
          return isValidCPassword(passwordTec.text, confirmPassTec.text);
        } else if (field == Values.agree) {
          if (isValidUsername(usernameTec.text) != null ||
              isValidEmail(emailTec.text) != null ||
              isValidPassword(passwordTec.text) != null ||
              isValidCPassword(passwordTec.text, confirmPassTec.text) != null) {
            return null;
          }
          return isAgreed(agree.value);
        } else {
          return null;
        }
      case LoginMode.forgotPassword:
        if (field == Values.enterEmail) {
          return isValidEmail(emailTec.text);
        } else {
          return null;
        }
      case LoginMode.changePassword:
        return null;
      case LoginMode.updateUserDetails:
        return null;
      case null:
        return null;
      case LoginMode.loading:
        return null;
      case LoginMode.failed:
        return null;
    }
  }

  String? isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (email.isEmpty) {
      return "This field cannot be left empty.";
    }
    if (!emailRegExp.hasMatch(email)) {
      return "Please enter a valid email id.";
    }
    return null;
  }

  void unifiedSubmitAction() {
    if (formKey.currentState?.validate() == true) {
      switch (mode.value) {
        case LoginMode.loggedIn:
          break;
        case LoginMode.login:
          doLogin();
          break;
        case LoginMode.register:
          register();
          break;
        case LoginMode.forgotPassword:
          forgotPassword();
          break;
        case LoginMode.changePassword:
          break;
        case LoginMode.updateUserDetails:
          break;
        case null:
          break;
        case LoginMode.loading:
          break;
        case LoginMode.failed:
          break;
      }
    }
  }

  String? isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$');
    if (password.isEmpty) {
      return "This field cannot be left empty.";
    }
    if (!passwordRegExp.hasMatch(password)) {
      return "Password must have at least 8 characters including letter/digit/special characters.";
    }
    return null;
  }

  String? isValidCPassword(String password, String confirm) {
    if (confirm.isEmpty) {
      return "This field cannot be left empty.";
    }
    if (confirm != password) {
      return "Confirm password should be same as password.";
    }
    return null;
  }

  String? isAgreed(bool? isAgree) {
    if (isAgree != true) {
      return "Please Accept the T&C to proceed with register.";
    }
    return null;
  }

  String? isValidUsername(String username) {
    final usernameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    if (username.isEmpty) {
      return "This field cannot be left empty.";
    }
    if (!usernameRegExp.hasMatch(username)) {
      return "Password must have at least 8 characters including letter/digit/special characters.";
    }
    return null;
  }

  String getLinkTitle() {
    if (mode.value == LoginMode.login) {
      return Values.notHavingAnAccount;
    }
    if (mode.value == LoginMode.forgotPassword) {
      return Values.backTo;
    }
    if (mode.value == LoginMode.register) {
      return Values.alreadyhaveAnAccount;
    }
    return "";
  }

  String getActionName() {
    if (mode.value == LoginMode.login) {
      return Values.login;
    }
    if (mode.value == LoginMode.forgotPassword) {
      return Values.forgotPassword;
    }
    if (mode.value == LoginMode.register) {
      return Values.register;
    }
    return "";
  }

  MapEntry<String, LoginMode> getLink() {
    if (mode.value == LoginMode.login) {
      return const MapEntry(Values.register, LoginMode.register);
    }
    if (mode.value == LoginMode.forgotPassword) {
      return const MapEntry(Values.login1, LoginMode.login);
    }
    if (mode.value == LoginMode.register) {
      return const MapEntry(Values.login1, LoginMode.login);
    }
    return const MapEntry(Values.register, LoginMode.register);
  }

  final TextEditingController playlistName = TextEditingController();
  initialize() {
    box = GetStorage();
    log("initialized");
    update();
  }

  void onClear() {
    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  void onCreatePlaylist() {
    Get.focusScope?.unfocus();

    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  metadataFromThemeId(List<String> themeIds) async {
    listings.clear();

    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    int successCount = 0;
    for (int i = 0; i < themeIds.length; i++) {
      if (box.hasData('theme_${themeIds[i]}')) {
        listings.add(AudioEntry.fromJson(box.read('theme_${themeIds[i]}')));
        successCount++;
        continue;
      }

      if (successCount == 0 && i + 1 < themeIds.length) {
        status = RxStatus.error("Something went wrong");
        update(["detail"]);
      }
    }
    if (listings.isEmpty) {
      status = RxStatus.empty();
    } else {
      status = RxStatus.success();
    }
    update(["detail"]);
  }

  Future playCurrentListing() async {
    if (listings.isNotEmpty) {
      Get.find<DashboardController>().init(listings);
    }
  }

  Future register() async {
    wait.value = true;
    await playlistRepo.getCookie();
    await playlistRepo.getToken();
    final response = await playlistRepo.registerUser(
      userName: usernameTec.text,
      email: emailTec.text,
      password: passwordTec.text,
      cPassword: confirmPassTec.text,
      terms: agree.value,
    );
    wait.value = false;
    toastMessage.value = response.message;
    update();
  }

  Future forgotPassword() async {
    wait.value = true;
    await playlistRepo.getCookie();
    await playlistRepo.getToken();
    final response = await playlistRepo.forgotPassword(email: emailTec.text);
    wait.value = false;
    toastMessage.value = response.message;
    update();
  }

  Future doLogin() async {
    wait.value = true;
    await playlistRepo.getCookie();
    await playlistRepo.getToken();
    await playlistRepo.loginUser(
      email: emailTec.text,
      password: passwordTec.text,
      remember: rememberMe.value,
    );
    final isLogin = await playlistRepo.getUserDetails();
    wait.value = false;
    if (isLogin.status) {
      final DashboardController dashboardController =
          Get.find<DashboardController>();
      dashboardController.me = meFromJson(isLogin.data);
      mode.value = LoginMode.loggedIn;
      update();
    } else {
      toastMessage.value = isLogin.message;
    }
  }

  Future doLogout() async {
    wait.value = true;
    await playlistRepo.getCookie();
    await playlistRepo.getToken();
    wait.value = false;
    mode.value = LoginMode.login;
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    toastMessage.value =
        "${dashboardController.me?.user.name} logged out successfully";
    dashboardController.me = null;
    update();
  }

  @override
  void dispose() {
    scroll.dispose();
    listings.clear();
    networkCalls.dispose();
    super.dispose();
  }
}
