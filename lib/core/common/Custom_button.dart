
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onpressed ;
  final String? text ;
  final Widget? child ;

  const CustomButton({
    super.key,
    required this.onpressed,
    this.text ,
    this.child,
    }):assert(text!= null || child!= null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onpressed == null
          ? null
          : ()async{
            await onpressed?.call() ;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.black,
            elevation: 2,
            shadowColor:Color(0xffaf7ac5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
            animationDuration: Duration(seconds: 1),
            padding: EdgeInsets.all(12.0),

          ),
          child: child??
           Text(text!,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white ,
              fontWeight: FontWeight.w700,
            ),
           ),
      ),
    );
  }
}
