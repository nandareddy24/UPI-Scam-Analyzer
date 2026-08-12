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
fun ReportScreen(navController: NavController, viewModel: ScamViewModel) {
    var type by remember { mutableStateOf("UPI") }
    var data by remember { mutableStateOf("") }
    var reason by remember { mutableStateOf("") }
    
    val isLoading by viewModel.isLoading

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Report Scam") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(24.dp).fillMaxSize()) {
            Text(text = "Help the community by reporting fraud", fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(16.dp))
            
            OutlinedTextField(
                value = data,
                onValueChange = { data = it },
                label = { Text("Fraudulent Data (UPI/Phone/URL)") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedTextField(
                value = reason,
                onValueChange = { reason = it },
                label = { Text("Description / Reason") },
                modifier = Modifier.fillMaxWidth().height(120.dp)
            )
            Spacer(modifier = Modifier.height(24.dp))
            Button(
                onClick = { viewModel.reportScam(type, data, reason, null) },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading && data.isNotBlank() && reason.isNotBlank()
            ) {
                if (isLoading) CircularProgressIndicator(modifier = Modifier.size(24.dp)) else Text("Submit Report")
            }
        }
    }
}
