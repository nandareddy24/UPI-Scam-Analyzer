package com.scamshield.ai.ui.screens

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.scamshield.ai.viewmodel.ScamViewModel
import java.io.File
import java.io.FileOutputStream

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OcrScanScreen(navController: NavController, viewModel: ScamViewModel) {
    val context = LocalContext.current
    var imageUri by remember { mutableStateOf<Uri?>(null) }
    val result by viewModel.scanResult
    val isLoading by viewModel.isLoading

    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        imageUri = uri
        uri?.let {
            val file = uriToFile(context, it)
            viewModel.scanOcr(file)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Image / OCR Scan") },
                navigationIcon = {
                    IconButton(onClick = { navController.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.padding(padding).padding(24.dp).fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Button(onClick = { launcher.launch("image/*") }) {
                Text("Select Screenshot from Gallery")
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            if (isLoading) {
                CircularProgressIndicator()
            }
            
            result?.let { res ->
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Verdict: ${res.result}", fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
                        Text(text = res.reason)
                    }
                }
            }
        }
    }
}

private fun uriToFile(context: android.content.Context, uri: Uri): File {
    val file = File(context.cacheDir, "temp_image.jpg")
    val inputStream = context.contentResolver.openInputStream(uri)
    val outputStream = FileOutputStream(file)
    inputStream?.copyTo(outputStream)
    inputStream?.close()
    outputStream.close()
    return file
}
