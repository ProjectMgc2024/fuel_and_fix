import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuel_and_fix/user/intro.dart'; // Your existing screen

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  String otp = "";
  bool hasError = false;

  // Function to check if the OTP is numeric
  bool isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(95, 149, 136, 122),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Please enter the OTP sent to your phone/email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),

              // OTP Input using pin_code_fields
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(15),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[200]!,
                  selectedFillColor: Colors.blueAccent,
                  inactiveColor: Colors.blueAccent,
                  selectedColor: Colors.blueAccent,
                ),
                controller: _otpController,
                onChanged: (value) {
                  setState(() {
                    otp = value;
                  });
                },
                onCompleted: (value) {
                  // Store the value when OTP is complete
                  otp = value;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button with gradient background
              ElevatedButton(
                onPressed: () {
                  // Check if OTP length is valid and if it contains only numbers
                  if (otp.length == 6 && isNumeric(otp)) {
                    // OTP is valid, show success toast
                    Fluttertoast.showToast(
                        msg: "OTP Verified!", gravity: ToastGravity.BOTTOM);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Introscreen()),
                    );
                  } else {
                    // OTP is invalid or not numeric, show error toast
                    Fluttertoast.showToast(
                        msg: "Please enter a valid 6-digit OTP",
                        gravity: ToastGravity.BOTTOM);
                  }
                },
                child: const Text('Verify OTP'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 20), // Spacer between buttons

              // Resend OTP Button
              TextButton(
                onPressed: () {
                  // Resend OTP action - simulate resend
                  Fluttertoast.showToast(
                      msg: "OTP has been resent!",
                      gravity: ToastGravity.BOTTOM);
                },
                child: const Text(
                  'Resend OTP?',
                  style: TextStyle(color: Color.fromARGB(255, 243, 61, 33)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
