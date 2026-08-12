package com.scamshield.ai

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.scamshield.ai.ui.ScamShieldApp
import com.scamshield.ai.ui.theme.ScamShieldTheme
import com.scamshield.ai.viewmodel.AuthViewModel
import com.scamshield.ai.viewmodel.ScamViewModel

class MainActivity : ComponentActivity() {
    private val authViewModel: AuthViewModel by viewModels()
    private val scamViewModel: ScamViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            ScamShieldTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    ScamShieldApp(authViewModel, scamViewModel)
                }
            }
        }
    }
}
