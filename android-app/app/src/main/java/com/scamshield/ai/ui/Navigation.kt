package com.scamshield.ai.ui

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.scamshield.ai.ui.screens.*
import com.scamshield.ai.viewmodel.AuthViewModel
import com.scamshield.ai.viewmodel.ScamViewModel

@Composable
fun ScamShieldApp(authViewModel: AuthViewModel, scamViewModel: ScamViewModel) {
    val navController = rememberNavController()
    val startDestination = "splash"

    NavHost(navController = navController, startDestination = startDestination) {
        composable("splash") {
            SplashScreen(navController, authViewModel)
        }
        composable("login") {
            LoginScreen(navController, authViewModel)
        }
        composable("register") {
            RegisterScreen(navController, authViewModel)
        }
        composable("verify_registration/{email}") { backStackEntry ->
            val email = backStackEntry.arguments?.getString("email") ?: ""
            VerifyRegistrationScreen(navController, authViewModel, email)
        }
        composable("forgot") {
            ForgotScreen(navController, authViewModel)
        }
        composable("reset_password/{email}") { backStackEntry ->
            val email = backStackEntry.arguments?.getString("email") ?: ""
            ResetPasswordScreen(navController, authViewModel, email)
        }
        composable("dashboard") {
            DashboardScreen(navController, authViewModel, scamViewModel)
        }
        composable("upi") {
            UpiScanScreen(navController, scamViewModel)
        }
        composable("phone") {
            PhoneScanScreen(navController, scamViewModel)
        }
        composable("sms") {
            SmsScanScreen(navController, scamViewModel)
        }
        composable("url") {
            UrlScanScreen(navController, scamViewModel)
        }
        composable("history") {
            HistoryScreen(navController, scamViewModel)
        }
        composable("report") {
            ReportScreen(navController, scamViewModel)
        }
        composable("qr") {
            QrScanScreen(navController, scamViewModel)
        }
        composable("ocr") {
            OcrScanScreen(navController, scamViewModel)
        }
        composable("profile") {
            ProfileScreen(navController, authViewModel)
        }
        composable("settings") {
            SettingsScreen(navController)
        }
        composable("admin") {
            AdminScreen(navController, authViewModel)
        }
    }
}
