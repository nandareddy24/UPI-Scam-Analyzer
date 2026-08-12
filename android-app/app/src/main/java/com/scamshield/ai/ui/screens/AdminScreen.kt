package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Security
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminScreen(navController: NavController, viewModel: AuthViewModel) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Admin Console") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        if (!viewModel.isAdmin) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Access Denied", fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.error)
            }
        } else {
            Column(modifier = Modifier.padding(padding).padding(24.dp)) {
                Icon(Icons.Default.Security, contentDescription = null, modifier = Modifier.size(48.dp), tint = MaterialTheme.colorScheme.error)
                Spacer(modifier = Modifier.height(16.dp))
                Text("Administrative Tasks", style = MaterialTheme.typography.headlineSmall)
                Spacer(modifier = Modifier.height(24.dp))
                
                // Placeholder for admin actions
                Text("• Review Community Reports")
                Text("• Manage Global Blacklist")
                Text("• View System Audit Logs")
                
                Spacer(modifier = Modifier.height(32.dp))
                Text("Note: These actions directly affect the global database used by both Web and Mobile platforms.", style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
