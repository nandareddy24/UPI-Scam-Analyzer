package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.AuthViewModel
import com.scamshield.ai.viewmodel.ScamViewModel

data class DashboardItem(val title: String, val icon: ImageVector, val route: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(navController: NavController, authViewModel: AuthViewModel, scamViewModel: ScamViewModel) {
    val items = listOf(
        DashboardItem("UPI Check", Icons.Default.AccountBalance, "upi"),
        DashboardItem("Phone Check", Icons.Default.Phone, "phone"),
        DashboardItem("SMS Analyze", Icons.Default.Message, "sms"),
        DashboardItem("URL Scan", Icons.Default.Language, "url"),
        DashboardItem("QR Scanner", Icons.Default.QrCodeScanner, "qr"),
        DashboardItem("Image/OCR", Icons.Default.Image, "ocr"),
        DashboardItem("History", Icons.Default.History, "history"),
        DashboardItem("Report", Icons.Default.Report, "report")
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Scam Shield Dashboard") },
                actions = {
                    IconButton(onClick = { authViewModel.logout(); navController.navigate("login") { popUpTo(0) } }) {
                        Icon(Icons.Default.ExitToApp, contentDescription = "Logout")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(16.dp)) {
            Text(
                text = "Welcome back!",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            Text(
                text = "Protecting you from cyber fraud",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.secondary,
                modifier = Modifier.padding(bottom = 24.dp)
            )

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(items) { item ->
                    Card(
                        onClick = { navController.navigate(item.route) },
                        modifier = Modifier.fillMaxWidth().height(120.dp)
                    ) {
                        Column(
                            modifier = Modifier.fillMaxSize(),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(item.icon, contentDescription = item.title, modifier = Modifier.size(32.dp))
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(item.title, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
            }
        }
    }
}
