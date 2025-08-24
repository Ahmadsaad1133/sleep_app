import 'package:flutter/material.dart';
import '../../constants/fonts.dart';
import '../Sleep_lognInput_page/sleep_loginput/sleep_loginput_page_state.dart';

class AnalysisPromoCard extends StatelessWidget {
  final double Function(double) scale;

  const AnalysisPromoCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scale(20), vertical: scale(14)),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage('assets/images/sleepback2.png'),
            fit: BoxFit.cover
        ),
        color: Colors.blueAccent.shade700.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: Colors.blueAccent.shade200.withOpacity(.6),
            blurRadius: 12,
            offset: const Offset(0, 6)
        )],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
            'Get your sleep analysis with AI now!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontFamily: AppFonts.AirbnbCerealBook
            )
        ),
        SizedBox(height: scale(12)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: EdgeInsets.symmetric(horizontal: scale(18), vertical: scale(12)),
              elevation: 8,
              shadowColor: Colors.blueAccent.shade100
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SleepLogInputPage())
          ),
          child: Text(
              'Analyze',
              style: TextStyle(
                  color: Colors.blueAccent.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: scale(14)
              )
          ),
        ),
      ]),
    );
  }
}