package com.scamshield.ai.repository

import android.content.Context
import com.scamshield.ai.api.RetrofitClient

class AuthRepository(context: Context) {
    private val api = RetrofitClient.getApiService(context)

    suspend fun login(email: String, pass: String) = api.login(mapOf("email" to email, "password" to pass))
    
    suspend fun register(name: String, email: String, pass: String) = 
        api.register(mapOf("name" to name, "email" to email, "password" to pass))
    
    suspend fun getProfile() = api.getProfile()
}
