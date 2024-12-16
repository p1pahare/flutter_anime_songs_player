import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/animated_size_and_fade.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:anime_themes_player/widgets/text_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistFormsPage extends StatelessWidget {
  const PlaylistFormsPage({
    super.key,
    required PlaylistController pc,
  }) : _pc = pc;

  final PlaylistController _pc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Form(
            key: _pc.formKey,
            child: Column(
              children: [
                AnimatedSizeAndFade(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      _pc.getTitle(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                AnimatedSizeAndFade.showHide(
                  show: _pc.showUsername(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pc.usernameTec,
                      validator: (str) =>
                          _pc.unifiedValidator(Values.enterUsername),
                      decoration:
                          getTextFieldDecoration(context, Values.enterUsername),
                    ),
                  ),
                ),
                AnimatedSizeAndFade.showHide(
                  show: _pc.showEmail(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pc.emailTec,
                      validator: (str) =>
                          _pc.unifiedValidator(Values.enterEmail),
                      decoration:
                          getTextFieldDecoration(context, Values.enterEmail),
                    ),
                  ),
                ),
                AnimatedSizeAndFade.showHide(
                  show: _pc.showOldPassword(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pc.oldPasswordTec,
                      validator: (str) =>
                          _pc.unifiedValidator(Values.enterPassword),
                      decoration:
                          getTextFieldDecoration(context, Values.enterPassword),
                    ),
                  ),
                ),
                AnimatedSizeAndFade.showHide(
                  show: _pc.showPassoword(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pc.passwordTec,
                      obscureText: true,
                      validator: (str) =>
                          _pc.unifiedValidator(Values.enterPassword),
                      decoration:
                          getTextFieldDecoration(context, Values.enterPassword),
                    ),
                  ),
                ),
                AnimatedSizeAndFade.showHide(
                  show: _pc.showCPassoword(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _pc.confirmPassTec,
                      obscureText: true,
                      validator: (str) =>
                          _pc.unifiedValidator(Values.reenterPassword),
                      decoration: getTextFieldDecoration(
                          context, Values.reenterPassword),
                    ),
                  ),
                ),
                if (_pc.showAgree()) AgreeTCPP(pc: _pc),
                if (_pc.showRemember()) RememberForgot(pc: _pc),
                Obx(() {
                  if (_pc.toastMessage.value.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _pc.toastMessage.value,
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(color: Get.theme.colorScheme.error),
                    ),
                  );
                }),
                Obx(() {
                  return _pc.wait.value
                      ? const Center(
                          child: ProgressIndicatorButton(
                            radius: 20,
                          ),
                        )
                      : OutlinedButton(
                          onPressed: _pc.unifiedSubmitAction,
                          child: Text(_pc.getActionName()),
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).cardColor),
                              ),
                        );
                }),
                SignUpRow(
                  pc: _pc,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AgreeTCPP extends StatelessWidget {
  const AgreeTCPP({
    super.key,
    required PlaylistController pc,
  }) : _pc = pc;

  final PlaylistController _pc;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: (value) => _pc.unifiedValidator(Values.agree),
      builder: (field) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                  value: _pc.agree.value,
                  onChanged: (agree) {
                    _pc.setAgree(agree);
                  }),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 9, 0, 9),
                child: Text(
                  Values.agree,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.find<DashboardController>().launchURL(Values.tncUrl);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
                    child: Text(
                      Values.tAC,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 9, 0, 9),
                child: Text(
                  Values.and,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.find<DashboardController>().launchURL(Values.privacyUrl);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 9, 18, 9),
                    child: Text(
                      Values.privacyPolicy,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                field.errorText ?? "",
                textAlign: TextAlign.left,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
        ],
      ),
    );
  }
}

class RememberForgot extends StatelessWidget {
  const RememberForgot({
    super.key,
    required PlaylistController pc,
  }) : _pc = pc;

  final PlaylistController _pc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
            value: _pc.rememberMe.value,
            onChanged: (remembr) {
              _pc.setRememberMe(remembr);
            }),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 9, 0, 9),
                child: Text(
                  Values.rememberMe,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              InkWell(
                onTap: () {
                  _pc.setMode(LoginMode.forgotPassword);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
                    child: Text(
                      Values.forgotPassword,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SignUpRow extends StatelessWidget {
  const SignUpRow({super.key, required PlaylistController pc}) : _pc = pc;
  final PlaylistController _pc;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 0, 18),
          child: Text(
            _pc.getLinkTitle(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        InkWell(
          onTap: () {
            _pc.setMode(_pc.getLink().value);
          },
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 18, 18, 18),
              child: Text(
                _pc.getLink().key,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
