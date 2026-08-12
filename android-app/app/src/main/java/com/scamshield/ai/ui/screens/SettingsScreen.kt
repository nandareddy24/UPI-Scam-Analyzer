package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(navController: NavController) {
    var pushEnabled by remember { mutableStateOf(true) }
    var autoScanEnabled by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(16.dp)) {
            ListItem(
                headlineContent = { Text("Push Notifications") },
                supportingContent = { Text("Receive alerts for new threats") },
                trailingContent = {
                    Switch(checked = pushEnabled, onCheckedChange = { pushEnabled = it })
                }
            )
            ListItem(
                headlineContent = { Text("Auto-Scan Links") },
                supportingContent = { Text("Automatically analyze URLs in background") },
                trailingContent = {
                    Switch(checked = autoScanEnabled, onCheckedChange = { autoScanEnabled = it })
                }
            )
            Divider()
            ListItem(
                headlineContent = { Text("App Version") },
                trailingContent = { Text("1.0.0") }
            )
        }
    }
}
