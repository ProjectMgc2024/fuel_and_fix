import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/intro.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(95, 149, 136, 122),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
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

                // OTP Input Fields in separate boxes with styling and space between boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0), // Space between each box
                      child: SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "-",
                            hintStyle: TextStyle(
                                fontSize: 24, color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          keyboardType:
                              TextInputType.number, // Ensures number input only
                          maxLength: 1, // Only one character per box
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          // Validator to ensure the input is a number
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a digit';
                            }
                            if (!RegExp(r'^[0-9]$').hasMatch(value)) {
                              return 'Only digits are allowed';
                            }
                            return null;
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),

                // Submit Button with gradient background and rounded corners
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Show a Snackbar and navigate to the next page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP Verified!')),
                      );
                      // Navigate to the home screen (or next page)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Introscreen()),
                      );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP has been resent!')),
                    );
                    // You can add an API call here to resend the OTP if needed
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
      ),
    );
  }
}
