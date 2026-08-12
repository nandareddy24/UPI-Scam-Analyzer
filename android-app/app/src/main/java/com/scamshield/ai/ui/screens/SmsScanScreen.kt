package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.ScamViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SmsScanScreen(navController: NavController, viewModel: ScamViewModel) {
    var sms by remember { mutableStateOf("") }
    val result by viewModel.scanResult
    val isLoading by viewModel.isLoading

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("SMS Analyzer") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(24.dp)) {
            OutlinedTextField(
                value = sms,
                onValueChange = { sms = it },
                label = { Text("SMS Content") },
                modifier = Modifier.fillMaxWidth().height(120.dp)
            )
            Spacer(modifier = Modifier.height(24.dp))
            Button(
                onClick = { viewModel.scanSms(sms) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading && sms.isNotBlank()
            ) {
                if (isLoading) CircularProgressIndicator(modifier = Modifier.size(24.dp)) else Text("Analyze SMS")
            }
            Spacer(modifier = Modifier.height(32.dp))
            result?.let { res ->
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Verdict: ${res.result}", fontWeight = FontWeight.Bold)
                        Text(text = res.reason)
                    }
                }
            }
        }
    }
}
