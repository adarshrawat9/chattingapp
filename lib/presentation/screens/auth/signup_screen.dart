import 'package:chattingapp/core/common/Custom_button.dart';
import 'package:chattingapp/logic/cubits/auth/auth_cubit.dart';
import 'package:chattingapp/logic/cubits/auth/auth_state.dart';
import 'package:chattingapp/presentation/screens/auth/Login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chattingapp/data/services/service_locator.dart';
import 'package:chattingapp/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/common/custom_TextField.dart';
import '../../../core/utils/ui_utils.dart';
import '../../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final nameFocus = FocusNode();
  final usernameFocus =FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final phoneFocus = FocusNode();


  bool myobscure = true ;

  @override
  void dispose() {
  nameController.dispose();
  usernameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  phoneController.dispose();

    super.dispose();
  }

  String? _namevalidate(String? value){
    if(value == null || value.isEmpty){
      return "Please enter a valid name" ;
    }
  }
  String? _usernamevalidate(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your username" ;
    }
      if (value.length < 3) {
        return "username must be at least 3 characters long";
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
        return "username can only contain letters, numbers, and underscores";
      }
    
  }
  String ? _emailvalidate(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your email" ;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email address";
    }
  }
  String? _phonevalidate(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number with country code.";
    }
    final RegExp phoneRegex = RegExp(r'^\+\d{7,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return "Please enter a valid international phone number (e.g., +1234567890).";
    }
    return null;
  }
  String ? _passvalidate(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your password" ;
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
  }
  

  Future<void> handleSignUp()async{
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try{
        await getit<AuthCubit>().signUp(
            fullName: nameController.text,
            userName : usernameController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
            password: passwordController.text
        );
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit ,AuthState>(
      bloc: getit<AuthCubit>() ,
      listener: (context , state)async{
        if(state.status == AuthStatus.authenticated){
         await getit<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        }
        else if (state.status == AuthStatus.unauthenticated && state.error != null){
          UiUtils.customSnackBar(context,isError: true, message: state.error!);
        }
      },
      builder: (context , state) {
        return FocusScope(
          child: Scaffold(
            appBar: AppBar(
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Create Account", style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 40)),
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Enter the Required Fields to Continue",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),),
                    ),

                    SizedBox(
                      height: 35,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextfield(
                        controller: nameController,
                        hintText: "Name",
                        focusNode: nameFocus,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _namevalidate(value),
                        contentpadding: EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Icon(Icons.person_2_outlined),
                        hintstyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextfield(
                        controller: usernameController,
                        hintText: "User Name",
                        focusNode: usernameFocus,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _usernamevalidate(value),
                        contentpadding: EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                        hintstyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextfield(
                        controller: emailController,
                        hintText: "Email",
                        focusNode: emailFocus,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _emailvalidate(value),
                        contentpadding: EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Icon(Icons.email_outlined),
                        hintstyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextfield(
                        controller: passwordController,
                        hintText: "Password",
                        focusNode: passwordFocus,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _passvalidate(value),
                        contentpadding: EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: Icon(Icons.lock_outline),
                        obscureText: myobscure,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                myobscure = !myobscure;
                              });
                            },
                            icon: myobscure ? Icon(Icons.visibility) : Icon(
                                Icons.visibility_off)),
                        hintstyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IntlPhoneField(
                        controller: phoneController,
                        initialCountryCode: 'IN',
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (phone) {
                          print(phone.completeNumber); // Always in +91xxxx format
                        },
                        validator: (phone) {
                          if (phone == null || phone.completeNumber.isEmpty) {
                            return "Enter a valid phone number";
                          }
                          return null;
                        },
                      )
                    ),
                    SizedBox(
                      height: 35,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomButton(
                        onpressed: () {
                          handleSignUp();
                        },
                        text: "continue",
                      ),
                    ),

                    SizedBox(
                      height: 24,
                    ),
                    Center(
                      child: RichText(
                          text: TextSpan(
                              text: "Already have an account  ",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              children: [
                                TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                      color: Theme
                                          .of(context).colorScheme.primary,
                                      fontSize: 18,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        getit<AppRouter>().pushReplacement(LoginScreen());
                                      }
                                ),
                              ]
                          )
                      ),
                    ),


                  ],

                ),
              ),
            ),
          ),
        );

      }
    );
  }
}
