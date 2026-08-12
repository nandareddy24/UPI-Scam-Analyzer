package com.scamshield.ai.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.ScamViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HistoryScreen(navController: NavController, viewModel: ScamViewModel) {
    val history by viewModel.history
    val isLoading by viewModel.isLoading

    LaunchedEffect(Unit) {
        viewModel.fetchHistory()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Scan History") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        if (isLoading && history.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
                CircularProgressIndicator()
            }
        } else {
            LazyColumn(modifier = Modifier.padding(padding).fillMaxSize().padding(16.dp)) {
                items(history) { item ->
                    Card(
                        modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text(text = item.type, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                                Text(text = item.result, fontWeight = FontWeight.Bold, color = when(item.result) {
                                    "Safe" -> MaterialTheme.colorScheme.primary
                                    "Warning" -> androidx.compose.ui.graphics.Color(0xFFFFA000)
                                    else -> MaterialTheme.colorScheme.error
                                })
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(text = item.data, fontSize = 14.sp)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(text = "Threat Score: ${item.score}", fontSize = 12.sp, color = MaterialTheme.colorScheme.secondary)
                            Text(text = item.date, fontSize = 10.sp, color = MaterialTheme.colorScheme.outline)
                        }
                    }
                }
            }
        }
    }
}
