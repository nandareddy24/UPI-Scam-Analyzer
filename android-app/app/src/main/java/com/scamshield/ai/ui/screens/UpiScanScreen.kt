package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.ScamViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UpiScanScreen(navController: NavController, viewModel: ScamViewModel) {
    var upi by remember { mutableStateOf("") }
    val result by viewModel.scanResult
    val isLoading by viewModel.isLoading
    val error by viewModel.error

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("UPI Scam Checker") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(24.dp)) {
            Text(
                text = "Enter UPI ID to check",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            OutlinedTextField(
                value = upi,
                onValueChange = { upi = it },
                label = { Text("UPI ID (e.g. user@bank)") },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = { viewModel.scanUpi(upi) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading && upi.isNotBlank()
            ) {
                if (isLoading) {
                    CircularProgressIndicator(modifier = Modifier.size(24.dp), color = MaterialTheme.colorScheme.onPrimary)
                } else {
                    Text("Analyze UPI ID")
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            error?.let {
                Text(text = "Error: $it", color = MaterialTheme.colorScheme.error)
            }

            result?.let { res ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = when (res.result) {
                            "Safe" -> MaterialTheme.colorScheme.primaryContainer
                            "Warning" -> MaterialTheme.colorScheme.secondaryContainer
                            else -> MaterialTheme.colorScheme.errorContainer
                        }
                    )
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Result: ${res.result}", fontWeight = FontWeight.Bold, fontSize = 20.sp)
                        Text(text = "Threat Score: ${res.score}/25")
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(text = res.reason)
                        res.advice?.let {
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(text = "Advice: $it", fontStyle = androidx.compose.ui.text.font.FontStyle.Italic)
                        }
                    }
                }
            }
        }
    }
}
