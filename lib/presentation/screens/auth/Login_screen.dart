import 'package:chattingapp/config/theme/app_theme.dart';
import 'package:chattingapp/core/common/Custom_button.dart';
import 'package:chattingapp/core/common/custom_TextField.dart';
import 'package:chattingapp/logic/cubits/auth/auth_state.dart';
import 'package:chattingapp/presentation/screens/auth/signup_screen.dart';
import 'package:chattingapp/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/storage_helper.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../data/services/service_locator.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  FocusNode emailfocus = FocusNode();
  FocusNode passwordfocus = FocusNode();
  bool myobscure = true ;

  String? _emailvalidator(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your email address" ;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email address";
    }
  }
  String? _passwordvalidator(String? value){
    if(value == null || value.isEmpty){
      return "Please enter your password" ;
    }
    if (value.length < 8) {
      return " invalid password ";
    }
  }

  @override
  void dispose(){
    emailcontroller.dispose();
    passcontroller.dispose();
    emailfocus.dispose();
    passwordfocus.dispose();
    super.dispose();
  }

  Future<void> handleSignIn()async{
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try{
        getit<AuthCubit>().signIn(
            email: emailcontroller.text,
            password: passcontroller.text
        );


      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit , AuthState>(
      bloc: getit<AuthCubit>() ,
      listener: (context , state) async{
        if(state.status == AuthStatus.authenticated){
        await getit<AppRouter>().pushAndRemoveUntil(const HomeScreen());
      }
      else if (state.status == AuthStatus.unauthenticated && state.error != null){
        UiUtils.customSnackBar(context,isError: true, message: state.error!);
      }
      },

      builder:(context , state) {
        return FocusScope
          (
          child: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SizedBox(
                    height: 180,
                  ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text("Welcome Back", style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 50),),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Padding(
                        padding: EdgeInsets.only(left: 18),
                        child: Text("Sign in to continue",
                          style: Theme
                              .of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: Colors.grey, fontSize: 16),)),

                    SizedBox(
                      height: 80,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomTextfield(controller: emailcontroller,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: _emailvalidator,
                          contentpadding: EdgeInsets.symmetric(vertical: 15),
                          focusNode: emailfocus,
                          hintstyle: TextStyle(
                            color: Colors.grey,),
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: "Enter your email"),
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: CustomTextfield(
                          controller: passcontroller,
                          prefixIcon: Icon(Icons.lock_outline),
                          focusNode: passwordfocus,
                          hintstyle: TextStyle(
                            color: Colors.grey,),
                          keyboardType: TextInputType.text,
                          contentpadding: EdgeInsets.symmetric(vertical: 15),
                          obscureText: myobscure,
                          validator: _passwordvalidator,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  myobscure = !myobscure;
                                });
                              },
                              icon: myobscure ? Icon(Icons.visibility) : Icon(
                                  Icons.visibility_off)),
                          hintText: "Enter your password"),
                    ),

                    SizedBox(
                      height: 40,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomButton(
                        onpressed: handleSignIn,
                        text: "Login",
                      child: state.status == AuthStatus.loading ? CircularProgressIndicator(color: Colors.white70,) : Text("Login" , style: TextStyle( color: Colors.white),),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account?  ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Signup",
                              style: TextStyle(color: Theme
                                  .of(context)
                                  .colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  getit<AppRouter>().pushReplacement(SignupScreen());
                                },
                            ),
                          ],
                        ),
                      ),
                    )
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
