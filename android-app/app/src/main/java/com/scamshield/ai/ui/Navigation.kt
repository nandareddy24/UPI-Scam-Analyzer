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
    val startDestination = if (authViewModel.isLoggedIn.value) "dashboard" else "login"

    NavHost(navController = navController, startDestination = startDestination) {
        composable("login") {
            LoginScreen(navController, authViewModel)
        }
        composable("register") {
            RegisterScreen(navController, authViewModel)
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
    }
}
