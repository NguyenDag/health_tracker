import 'package:flutter/material.dart';
import 'package:health_tracker/views/threshold/widgets/threshold_bar.dart';

class ThresholdsScreen extends StatefulWidget {
  const ThresholdsScreen({super.key});

  @override
  State<ThresholdsScreen> createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends State<ThresholdsScreen> {
  bool push = true;
  bool sms = true;
  bool morning = true;
  bool evening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Row(children: [Icon(Icons.arrow_back_ios)]),
        ),
        centerTitle: true,
        title: const Text(
          "Thresholds",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// SAFE RANGE
          const Text(
            "SAFE RANGES & THRESHOLDS",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          const ThresholdBar(
            title: "Blood Pressure (Systolic)",
            unit: "mmHg",
            min: "Min: 90",
            safe: "Safe: 90 - 120",
            max: "Max: 120",
          ),

          const ThresholdBar(
            title: "Blood Sugar",
            unit: "mg/dL",
            min: "Min: 70",
            safe: "Safe: 70 - 130",
            max: "Max: 130",
          ),

          const ThresholdBar(
            title: "SpO2 (Oxygen)",
            unit: "%",
            min: "Low: <95",
            safe: "Target: 95 - 100",
            max: "",
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DAILY CHECK-IN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Add new reminder logic
                },
                child: const Text(
                  "Add New",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Morning Measurement"),
            subtitle: const Text("08:00 AM"),
            value: morning,
            onChanged: (v) => setState(() => morning = v),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Evening Review"),
            subtitle: const Text("08:30 PM"),
            value: evening,
            onChanged: (v) => setState(() => evening = v),
          ),

          const SizedBox(height: 32),

          /// SAVE BUTTON
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D7BF7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Save Configuration",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
