package com.example.first_flutter_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yourcompany.yourapp.GeneratedAndroidFirebaseAuth

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GeneratedAndroidFirebaseAuth.AuthApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            object : GeneratedAndroidFirebaseAuth.AuthApi {
                override fun getPlatformVersion(): String {
                    return "Android ${android.os.Build.VERSION.RELEASE}"
                }
            }
        )
    }
}
