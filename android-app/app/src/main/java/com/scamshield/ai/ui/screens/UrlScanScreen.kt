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
fun UrlScanScreen(navController: NavController, viewModel: ScamViewModel) {
    var url by remember { mutableStateOf("") }
    val result by viewModel.scanResult
    val isLoading by viewModel.isLoading

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("URL Phishing Scan") },
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
                value = url,
                onValueChange = { url = it },
                label = { Text("URL (e.g. http://scam.com)") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(24.dp))
            Button(
                onClick = { viewModel.scanUrl(url) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading && url.isNotBlank()
            ) {
                if (isLoading) CircularProgressIndicator(modifier = Modifier.size(24.dp)) else Text("Scan URL")
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
