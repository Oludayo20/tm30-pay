import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/brand.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/thin_arrow.dart';
import '../../../../core/widgets/underline_text_field.dart';
import '../../domain/sign_up_validators.dart';
import '../birth_date_input_formatter.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../validation_messages.dart';
import '../widgets/auth_scroll_view.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/profile_wave.dart';

/// Step 4 of sign-up: photo, username, name and date of birth. "Complete"
/// creates the account; the router then moves to the wallet by itself.
class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();
    final width = MediaQuery.sizeOf(context).width;

    void submit() {
      FocusScope.of(context).unfocus();
      bloc.add(const SignUpProfileSubmitted());
    }

    return BlocListener<SignUpBloc, SignUpState>(
      listenWhen: (previous, current) =>
          current.step == SignUpStep.profile &&
          current.status == SignUpStatus.failure &&
          previous.status != SignUpStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: BrandColors.gradientEnd,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: BrandGradients.background,
            ),
            child: BlocBuilder<SignUpBloc, SignUpState>(
              builder: (context, state) {
                final submitting = state.isSubmitting(SignUpStep.profile);
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 300 * width / 375,
                      child: ProfileWave(visible: state.profileValid),
                    ),
                    SafeArea(
                      bottom: false,
                      child: AutofillGroup(
                        child: AuthScrollView(
                          bottomGap: 22,
                          top: _Form(state: state, onSubmit: submit),
                          bottom: BrandButton(
                            key: const Key('signUp_complete'),
                            label: 'Complete',
                            variant: BrandButtonVariant.light,
                            trailing: BrandButtonTrailing.check,
                            centered: true,
                            muted: !state.profileValid,
                            loading: submitting,
                            onPressed: submit,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.state, required this.onSubmit});

  final SignUpState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();
    final enabled = !state.isSubmitting(SignUpStep.profile);
    void blurred(SignUpField f) => bloc.add(SignUpFieldBlurred(f));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 38 + 145,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  left: -10,
                  top: 4,
                  child: IconButton(
                    tooltip: 'Back',
                    iconSize: 28,
                    onPressed: () => context.pop(),
                    icon: const ThinArrow(
                      color: Colors.white,
                      pointsLeft: true,
                      size: Size(28, 20),
                      strokeWidth: 1.6,
                    ),
                  ),
                ),
                Positioned(
                  top: 38,
                  child: ProfilePhotoPicker(
                    photoPath: state.photoPath,
                    onChanged: (p) => bloc.add(SignUpPhotoChanged(p)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          UnderlineTextField(
            key: const Key('signUp_username'),
            tone: UnderlineFieldTone.onBlue,
            label: 'Username',
            hintText: 'Your username',
            initialValue: state.username,
            enabled: enabled,
            showValid: state.usernameError == null,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newUsername],
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            errorText: state.visibleUsernameError?.message,
            onChanged: (v) => bloc.add(SignUpUsernameChanged(v)),
            onBlur: () => blurred(SignUpField.username),
          ),
          const SizedBox(height: _fieldGap),
          UnderlineTextField(
            key: const Key('signUp_firstName'),
            tone: UnderlineFieldTone.onBlue,
            label: 'First Name',
            hintText: 'Your name',
            initialValue: state.firstName,
            enabled: enabled,
            showValid: state.firstNameError == null,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            errorText: state.visibleFirstNameError?.message('first name'),
            onChanged: (v) => bloc.add(SignUpFirstNameChanged(v)),
            onBlur: () => blurred(SignUpField.firstName),
          ),
          const SizedBox(height: _fieldGap),
          UnderlineTextField(
            key: const Key('signUp_lastName'),
            tone: UnderlineFieldTone.onBlue,
            label: 'Last Name',
            hintText: 'Your last name',
            initialValue: state.lastName,
            enabled: enabled,
            showValid: state.lastNameError == null,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            errorText: state.visibleLastNameError?.message('last name'),
            onChanged: (v) => bloc.add(SignUpLastNameChanged(v)),
            onBlur: () => blurred(SignUpField.lastName),
          ),
          const SizedBox(height: _fieldGap),
          UnderlineTextField(
            key: const Key('signUp_birthDate'),
            tone: UnderlineFieldTone.onBlue,
            label: 'Date of Birth',
            hintText: 'Your birthday (${SignUpValidators.birthDatePattern})',
            initialValue: state.birthDate,
            enabled: enabled,
            showValid: state.birthDateError == null,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.birthday],
            inputFormatters: const [BirthDateInputFormatter()],
            errorText: state.visibleBirthDateError?.message,
            onChanged: (v) => bloc.add(SignUpBirthDateChanged(v)),
            onBlur: () => blurred(SignUpField.birthDate),
            onSubmitted: (_) => onSubmit(),
          ),
        ],
      ),
    );
  }

  static const double _fieldGap = 0;
}
