import 'package:findpix_flutter/ui/widgets/customButtomgreen.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import '../../../app/validators.dart';

import 'register_viewmodel.dart';
import 'register_view.form.dart';

@FormView(fields: [
  FormTextField(
    name: 'name',
    validator: FormValidators.validateText,
  ),
  FormTextField(
    name: 'email',
    validator: FormValidators.validateEmail,
  ),
  FormTextField(
    name: 'password',
    validator: FormValidators.validatePassword,
  ),
])
class RegisterView extends StackedView<RegisterViewModel> with $RegisterView {
  RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/logo.png',
                  height: 150,
                ),
              ),
              // const Text(
              //   "Register",
              //   style: TextStyle(
              //     fontSize: 32,
              //     fontWeight: FontWeight.w900,
              //   ),
              // ),
              Form(
                // key: F,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 350,
                        ),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 183, 186, 185),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            labelText: 'Full name',
                            errorText: viewModel.nameValidationMessage,
                            errorMaxLines: 2,
                          ),
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          focusNode: nameFocusNode,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 350,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 183, 186, 185),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            labelText: 'Email',
                            errorText: viewModel.emailValidationMessage,
                            errorMaxLines: 2,
                          ),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocusNode,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 350,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 183, 186, 185),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            labelText: 'Password',
                            errorText: viewModel.passwordValidationMessage,
                            errorMaxLines: 2,
                          ),
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          focusNode: passwordFocusNode,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomButtongreen(
                        onTap: viewModel.registerUser,
                        text: 'Sign Up',
                        isLoading: viewModel.isBusy,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  RegisterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterViewModel();

  @override
  void onViewModelReady(RegisterViewModel viewModel) {
    syncFormWithViewModel(viewModel);
    viewModel.onModelReady();
  }

  @override
  void onDispose(RegisterViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }
}
