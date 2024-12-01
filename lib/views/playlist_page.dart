import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/text_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlaylistController _pc = Get.find();
    return Container(
        color: Colors.transparent,
        child: GetBuilder<PlaylistController>(
          init: _pc,
          initState: (_) {},
          builder: (_) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            _pc.getTitle(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        if (_pc.showUsername())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _pc.usernameTec,
                              validator: (str) => null,
                              decoration: getTextFieldDecoration(
                                  context, Values.enterUsername),
                            ),
                          ),
                        if (_pc.showEmail())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _pc.emailTec,
                              validator: (str) => null,
                              decoration: getTextFieldDecoration(
                                  context, Values.enterEmail),
                            ),
                          ),
                        if (_pc.showPassoword())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _pc.passwordTec,
                              validator: (str) => null,
                              decoration: getTextFieldDecoration(
                                  context, Values.enterPassword),
                            ),
                          ),
                        if (_pc.showCPassoword())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _pc.confirmPassTec,
                              validator: (str) => null,
                              decoration: getTextFieldDecoration(
                                  context, Values.reenterPassword),
                            ),
                          ),
                        if (_pc.showAgree()) AgreeTCPP(pc: _pc),
                        if (_pc.showRemember()) RememberForgot(pc: _pc),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text(Values.login),
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style
                              ?.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).cardColor),
                                // other properties
                              ),
                        ),
                        SignUpRow(
                          pc: _pc,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
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
    return Row(
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
          onTap: () {},
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
          onTap: () {},
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
