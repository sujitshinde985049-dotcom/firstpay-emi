import 'package:firstpay/app/localization/app_strings.dart';
import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:firstpay/core/widgets/firstpay_logo.dart';
import 'package:firstpay/features/authentication/application/auth_controller.dart';
import 'package:firstpay/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:firstpay/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() != true) return;
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (succeeded) {
      TextInput.finishAutofillContext(shouldSave: _rememberMe);
    }
  }

  Future<void> _forgotPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.emailRequiredMessage)),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthUiState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage ?? next.successMessage;
      if (message != null &&
          message != previous?.errorMessage &&
          message != previous?.successMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360
                ? FirstPaySpacing.medium
                : FirstPaySpacing.large;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 480,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: FirstPaySpacing.large,
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: FirstPayLogo(fontSize: 36)),
                            const SizedBox(height: FirstPaySpacing.small),
                            Text(
                              AppStrings.tagline,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: FirstPayColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: FirstPaySpacing.xLarge),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  FirstPaySpacing.large,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      AppStrings.loginTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: FirstPayColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: FirstPaySpacing.small,
                                    ),
                                    Text(
                                      AppStrings.loginSubtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: FirstPayColors.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: FirstPaySpacing.large,
                                    ),
                                    AuthTextField(
                                      controller: _emailController,
                                      label: AppStrings.emailLabel,
                                      hint: AppStrings.emailHint,
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      requiredMessage:
                                          AppStrings.emailRequiredMessage,
                                    ),
                                    const SizedBox(
                                      height: FirstPaySpacing.medium,
                                    ),
                                    AuthTextField(
                                      controller: _passwordController,
                                      label: AppStrings.passwordLabel,
                                      hint: AppStrings.passwordHint,
                                      icon: Icons.lock_outline,
                                      textInputAction: TextInputAction.done,
                                      obscureText: _obscurePassword,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      requiredMessage:
                                          AppStrings.passwordRequiredMessage,
                                      suffixIcon: IconButton(
                                        tooltip: _obscurePassword
                                            ? AppStrings.showPassword
                                            : AppStrings.hidePassword,
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: FirstPaySpacing.small,
                                    ),
                                    CheckboxListTile(
                                      value: _rememberMe,
                                      onChanged: (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      dense: true,
                                      title: const Text(AppStrings.rememberMe),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: authState.isLoading
                                            ? null
                                            : _forgotPassword,
                                        child: const Text(
                                          AppStrings.forgotPassword,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: FirstPaySpacing.medium,
                                    ),
                                    AuthPrimaryButton(
                                      label: AppStrings.signIn,
                                      isLoading: authState.isLoading,
                                      onPressed: _submit,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: FirstPaySpacing.large),
                            Text(
                              AppStrings.versionLabel,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: FirstPayColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
