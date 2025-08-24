package com.yourcompany.yourapp;

import androidx.annotation.NonNull;
import com.yourcompany.yourapp.GeneratedAndroidFirebaseAuth;

public class AuthApiImpl implements GeneratedAndroidFirebaseAuth.AuthApi {

    @NonNull
    @Override
    public String getPlatformVersion() {
        return android.os.Build.VERSION.RELEASE; // or any version string you want to return
    }
}
